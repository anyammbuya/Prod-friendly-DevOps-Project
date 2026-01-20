#!/bin/bash
set -e

# ------------------------
# Update OS and install dependencies
# ------------------------
dnf upgrade -y || dnf update -y
dnf install -y wget git java-21-amazon-corretto awscli

# ------------------------
# Install Maven manually into /opt
# ------------------------
MAVEN_VERSION=3.9.11
cd /opt
wget https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz

tar -xvzf apache-maven-${MAVEN_VERSION}-bin.tar.gz
mv apache-maven-${MAVEN_VERSION} maven
rm -f apache-maven-${MAVEN_VERSION}-bin.tar.gz

# ------------------------
# Set environment variables
# ------------------------
cat <<'EOF' >> /etc/profile.d/maven.sh
export M2_HOME=/opt/maven
export M2=/opt/maven/bin
export JAVA_HOME=/usr/lib/jvm/java-21-amazon-corretto.x86_64
export PATH=$M2_HOME/bin:$JAVA_HOME/bin:$PATH
EOF
source /etc/profile.d/maven.sh

# ------------------------
# Create Jenkins user and group
# ------------------------
if ! id -u jenkins >/dev/null 2>&1; then
    groupadd jenkins
    useradd -r -g jenkins -d /var/lib/jenkins -s /sbin/nologin jenkins
fi

# ------------------------
# Prepare Jenkins home
# ------------------------
rm -rf /var/lib/jenkins/*
mkdir -p /var/lib/jenkins/init.groovy.d
mkdir -p /var/lib/jenkins/plugins
chown -R jenkins:jenkins /var/lib/jenkins
chmod 755 /var/lib/jenkins

# ------------------------
# Download latest Jenkins WAR (Jenkins 2.531)
# ------------------------
mkdir -p /usr/share/java
wget -O /usr/share/java/jenkins.war https://updates.jenkins-ci.org/latest/jenkins.war
chown jenkins:jenkins /usr/share/java/jenkins.war

# ------------------------
# Retrieve admin password from Secrets Manager
# ------------------------
SECRET_NAME="jenkins-admin-password"
AWS_REGION="us-west-2"
ADMIN_PASSWORD=$(aws secretsmanager get-secret-value \
  --secret-id "$SECRET_NAME" \
  --region "$AWS_REGION" \
  --query "SecretString" \
  --output text)

if [ -z "$ADMIN_PASSWORD" ]; then
    echo "Error: Failed to retrieve ADMIN_PASSWORD from Secrets Manager"
    exit 1
fi

# ------------------------
# Create admin user via init.groovy.d
# ------------------------
cat <<EOF > /var/lib/jenkins/init.groovy.d/01-create-admin.groovy
import jenkins.model.*
import hudson.security.*

def instance = Jenkins.get()
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount('admin', '${ADMIN_PASSWORD}')
instance.setSecurityRealm(hudsonRealm)
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)
instance.save()
EOF
chown -R jenkins:jenkins /var/lib/jenkins

# ------------------------
# Install Plugin Manager and plugins
# ------------------------
curl -L -o /opt/jenkins-plugin-manager.jar \
  https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.13.2/jenkins-plugin-manager-2.13.2.jar
chown jenkins:jenkins /opt/jenkins-plugin-manager.jar

mkdir -p /etc/jenkins
GITHUB_TOKEN=$(aws secretsmanager get-secret-value \
  --secret-id github-token \
  --region "us-west-2" \
  --query "SecretString" \
  --output text)

curl -H "Authorization: Bearer $GITHUB_TOKEN" \
     -L \
     "https://raw.githubusercontent.com/KingstonLtd/manage-jenkins/main/plugins.txt" \
     -o /etc/jenkins/plugins.txt

java -jar /opt/jenkins-plugin-manager.jar \
  --plugin-file /etc/jenkins/plugins.txt \
  --plugin-download-directory /var/lib/jenkins/plugins \
  --war /usr/share/java/jenkins.war \
  --clean-download-directory
chown -R jenkins:jenkins /var/lib/jenkins

# ------------------------
# Create update-jenkins-plugins.sh script
# ------------------------
cat <<'EOF' > /etc/jenkins/update-jenkins-plugins.sh
#!/bin/bash
set -e
echo "Stopping Jenkins..."
systemctl stop jenkins

GITHUB_TOKEN=$(aws secretsmanager get-secret-value \
  --secret-id github-token \
  --region us-west-2 \
  --query SecretString \
  --output text)

curl -H "Authorization: token $GITHUB_TOKEN" \
     -L \
     "https://raw.githubusercontent.com/KingstonLtd/manage-jenkins/main/plugins.txt" \
     -o /etc/jenkins/plugins.txt

java -jar /opt/jenkins-plugin-manager.jar \
  --plugin-file /etc/jenkins/plugins.txt \
  --plugin-download-directory /var/lib/jenkins/plugins \
  --war /usr/share/java/jenkins.war \
  --clean-download-directory

chown -R jenkins:jenkins /var/lib/jenkins
systemctl start jenkins
EOF
chmod +x /etc/jenkins/update-jenkins-plugins.sh

# ------------------------
# Set up Jenkins SSH for GitHub private repos
# We need the ssh key setup in order to be able to obtain web app files from a our repo
# -----------------------------------------------------------------------

mkdir -p /var/lib/jenkins/.ssh
chown jenkins:jenkins /var/lib/jenkins/.ssh
chmod 700 /var/lib/jenkins/.ssh


ssh-keyscan github.com >> /var/lib/jenkins/.ssh/known_hosts

# ---------------------------------------------------------------------------
# Ensure jenkins can use the publish-over-ssh plugin to ssh into Dockerhost
# The ssh keypair used for ssh with the github repo is the same keypair for ssh into dockerhost
# This block is commented out because i am using ssm
#-------------------------------------------------------------------------------

# DOCKERHOST_IP=$(aws ec2 describe-instances \
#   --filters "Name=tag:Name,Values=dockerhost" \
#   --query "Reservations[].Instances[].PrivateIpAddress" \
#   --output text \
#   --region us-west-2
# )
# ssh-keyscan -H $DOCKERHOST_IP >> /var/lib/jenkins/.ssh/known_hosts

chown jenkins:jenkins /var/lib/jenkins/.ssh/known_hosts
chmod 644 /var/lib/jenkins/.ssh/known_hosts

# ------------------------
# Set JCasC environment variable
# ------------------------
echo 'CASC_JENKINS_CONFIG=/var/lib/jenkins/jenkins.yaml' >> /etc/sysconfig/jenkins

# ------------------------------------------------------------------------------------
# Ensure /tmp has enough space
# -----------------------------------------------------------------------------------
mount -o remount,size=2G /tmp
grep -q '^tmpfs /tmp tmpfs' /etc/fstab || echo 'tmpfs /tmp tmpfs defaults,size=2G 0 0' | tee -a /etc/fstab

# ------------------------
# Create systemd service for Jenkins (WAR)
# ------------------------
cat <<EOF > /etc/systemd/system/jenkins.service
[Unit]
Description=Jenkins Daemon
After=network.target

[Service]
User=jenkins
Group=jenkins
Environment="JENKINS_HOME=/var/lib/jenkins"
Environment="CASC_RELOAD_TOKEN=${GITHUB_TOKEN}"
Environment="TOMCAT_PASS=deployer"
ExecStart=/usr/bin/java -jar /usr/share/java/jenkins.war
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

cat <<'EOF' > /etc/jenkins/update-jenkins-config.sh
#!/bin/bash
set -e
echo "Updating JCasC YAML (hot reload)..."

JENKINS_URL="http://localhost:8080"

# Get PAT from Secrets Manager
TOKEN=$(aws secretsmanager get-secret-value \
  --secret-id github-token \
  --region us-west-2 \
  --query SecretString \
  --output text)

# Download the latest jenkins.yml from repo
curl -H "Authorization: token $TOKEN" \
     -L \
     "https://raw.githubusercontent.com/KingstonLtd/manage-jenkins/main/jenkins.yaml" \
     -o /var/lib/jenkins/jenkins.yaml

echo "Waiting for jenkins.yaml to download"
sleep 15

chown jenkins:jenkins /var/lib/jenkins/jenkins.yaml

curl -X POST "${JENKINS_URL}/reload-configuration-as-code/?casc-reload-token=${TOKEN}"
EOF

chmod +x /etc/jenkins/update-jenkins-config.sh

systemctl daemon-reload
systemctl enable jenkins
systemctl start jenkins

echo "Jenkins installation and WAR-based setup completed successfully."

# cat /var/log/cloud-init-output.log   see logs on ec2 running jenkins
# journalctl -u jenkins    see logs on jenkins application server