#!/bin/bash
#set -xe

# Update system and install iptables
yum update -y
yum install -y iptables-services

# Enable IP forwarding
echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/90-nat.conf
sysctl --system

# Identify ENIs
ETH0_NAME=$(ip addr | grep device-number-0 | grep -oE 'device-number-.*$')
for i in {1..10}; do
  ETH1_NAME=$(ip addr | grep device-number-1 | grep -oE 'device-number-.*$')
  [[ -n "$ETH1_NAME" ]] && break
  sleep 3
done

# Resolve actual interface names
ETH0=$(ip -4 addr show $ETH0_NAME | grep -oP 'ens[0-9]+' | head -n1)
ETH1=$(ip -4 addr show $ETH1_NAME | grep -oP 'ens[0-9]+' | head -n1)

echo "Devices: public: $ETH0_NAME ($ETH0) and private: $ETH1_NAME ($ETH1)"

# Flush old rules
iptables -F
iptables -t nat -F
iptables -P FORWARD ACCEPT

# NAT rules (allow VPC-internal traffic direct, masquerade only Internet)
# Don't NAT traffic inside VPC CIDR (adjust to your VPC range)
iptables -t nat -A POSTROUTING -d 10.0.0.0/16 -j RETURN

# NAT everything else outbound via public interface
iptables -t nat -A POSTROUTING -o $ETH0 -j MASQUERADE

# Allow forwarding
iptables -A FORWARD -i $ETH0 -o $ETH1 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i $ETH1 -o $ETH0 -j ACCEPT

# Persist and enable
service iptables save
systemctl enable --now iptables

# Routing configuration
rm -rf /etc/systemd/network/70-$ETH1.network.d
mkdir -p /etc/systemd/network/70-$ETH1.network.d

# Example route template (you’d replace dynamically if templating with Terraform)
# Here we just put a placeholder — edit if you need static extra routes
cat <<EOF > /etc/systemd/network/70-$ETH1.network.d/routes.conf
# Example static route entries go here
EOF

networkctl reload

DATETIME=$(date)
echo "NAT instance setup complete at $DATETIME"
shutdown -r now