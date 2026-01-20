###########################################
# Launch Template Resource for Jenkins
###########################################

resource "aws_launch_template" "jenkins-LT" {
  
  name          = "jenkins-LT"
  description   = "Launch Template for jenkins server"
  image_id      = "ami-01102c5e8ab69fb75"
  instance_type = "t2.small"

  vpc_security_group_ids = [var.security_group_ids[0]]
  
  //key_name = var.key_name 
  
  user_data = filebase64("${path.module}/jenkinssetup_k8s.sh")

  iam_instance_profile {
    arn = var.instance_profile_arn[0]
  }

  
  //ebs_optimized = true
  
  #default_version = 1

  update_default_version = true
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 10     
      delete_on_termination = true
      volume_type = "gp3" # default is gp3
     }
  }
  monitoring {
    enabled = true
  }

  tag_specifications {
  resource_type = "instance"
  tags = merge(
    {
      Name = "Jenkins"
    },
    var.tags
  )
}
}

##########################################################
# Launch template resource for k8s
#######################################################

resource "aws_launch_template" "k8s-LT" {
  
  name          = "k8s-LT"
  description   = "Launch Template for k8s server"
  image_id      = "ami-07b2b18045edffe90"
  instance_type = "t4g.nano"

  vpc_security_group_ids = [var.security_group_ids[1]]
  
  //key_name = var.key_name 
  
  user_data = filebase64("${path.module}/k8s_bootstrapSetup.sh")

  iam_instance_profile {
    arn = var.instance_profile_arn[1]
   }

  
  //ebs_optimized = true
  
  #default_version = 1

  update_default_version = true
 
  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "k8sBootstrapHost"
      SSMTag = "ssmlinux"
    }
  }
}

##########################################################
# Launch template resource for ansible
#######################################################

resource "aws_launch_template" "ansible-LT" {
  
  name          = "ansible-LT"
  description   = "Launch Template for ansible server"
  image_id      = "ami-07b2b18045edffe90"
  instance_type = "t4g.nano"

  vpc_security_group_ids = [var.security_group_ids[1]]
  
  //key_name = var.key_name 
  
  user_data = filebase64("${path.module}/ansiblesetup.sh")

  iam_instance_profile {
    arn = var.instance_profile_arn[2]
   }

  
  //ebs_optimized = true
  
  #default_version = 1

  update_default_version = true
 
  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ansible-host"
      SSMTag = "ssmlinux"
    }
  }
}