
resource "aws_vpc_endpoint" "vpc-endpt" {
  for_each                =toset(["secretsmanager", "kms", "ssm", "ssmmessages"])
  vpc_id                  = var.vpc_id
  vpc_endpoint_type       = "Interface"
  security_group_ids      = var.vpc_endpt_sg_id_secretsM
  subnet_ids              = [var.subnet_ids]
  private_dns_enabled     = true
  service_name            = "com.amazonaws.${var.region}.${each.value}"
}

resource "aws_vpc_endpoint" "s3-endpt" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${var.region}.s3"
  route_table_ids = var.private_route_table_ids
}



/*
resource "aws_vpc_endpoint" "ec2msgs-endpt" {
  vpc_id                   = var.vpc_id
  vpc_endpoint_type        = "Interface"
  security_group_ids       = var.vpc_endpt_sg_id_secretsM
  subnet_ids               = [var.subnet_ids]
  private_dns_enabled      = true
  service_name             = "com.amazonaws.${var.region}.ec2messages"
}
*/
