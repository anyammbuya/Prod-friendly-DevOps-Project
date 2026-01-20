
variable "tags" {
  description = "tags"
}


variable "region" {
  description = "aws region"
}


variable "jenkins_policy" {
  description = "ssm access plus encryption of ssm session plus logging to s3 encrypted with kms"
}


variable "k8s_policy" {
  description = "ssm access plus encryption of ssm session plus logging to s3 encrypted with kms"
}

variable "ansible_policy" {
  description = "ssm access plus encryption of ssm session plus logging to s3 encrypted with kms"
}

  


