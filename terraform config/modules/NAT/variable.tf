variable "subnet_id_public" {
  description = "Subnet ID for NAT Instance"
}

variable "security_groups" {
  description = "Security group Id for jenkins server"
  type        = list(string)
}

variable "private_route_table_ids" {
  description = "route table of private subnets"
}

variable "subnet_id_private" {
  description = "private subnet_ids"
  }

variable "cidr_blocks_private" {
  description = "private subnet cidr_blocks"
}

variable "vpc_id" {
}
/*
variable "nat_ec2profile" {
  description = "ec2 instance profile - NAT"
}
*/