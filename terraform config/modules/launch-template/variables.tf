# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "tags" {
  description = "tags to apply to instances"
  type        = map(string)
}

variable "security_group_ids" {
  description = "Security group IDs for EC2 instances"
  
}

variable "instance_profile_arn" {
  description = "arn of the ec2 instance profile"
  
}

