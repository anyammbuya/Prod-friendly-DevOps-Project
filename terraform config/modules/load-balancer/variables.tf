variable "security_group_ids" {
  description = "Security group IDs for EC2 instances" 
}

variable "subnet_ids_public" {
  description = "Residence Subnets for loadbalancer "
  
}

variable "jenkins_autoscaling_group_name" {
  
}

variable "k8s_autoscaling_group_name" {
  
}

variable "vpc_id" {
  
}

variable "tags" {
  description = "vpc tags"
}