
variable "region" {
  description = "AWS region"
  }

variable "subnet_ids" {
  description = "private subnet_ids"
  }

variable "vpc_endpt_sg_id_secretsM"{
    description = "security id of vpc endpoint-secrets Manager"
}

variable "vpc_id" {
  description = "vpc id"
  }


variable "private_route_table_ids" {
  description = "private route table ids"
  }