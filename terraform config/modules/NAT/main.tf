resource "aws_instance" "NAT-instance" {

  ami                          = "ami-07b2b18045edffe90"
  instance_type                = "t4g.nano"
  subnet_id                    = var.subnet_id_public
  associate_public_ip_address  = true
  vpc_security_group_ids       = var.security_groups
  #iam_instance_profile         = var.nat_ec2profile

  user_data = file("${path.module}/userd.sh")
  source_dest_check           = false

  tags = {
    Name: "NAT"
  }
}

resource "aws_route" "private_nat_route" {

  #onvert var.private_route_table_ids from a tuple to a map  

  for_each               = { for idx, rt_id in var.private_route_table_ids : idx => rt_id }
  route_table_id         = each.value
  #route_table_id         = var.private_route_table_ids[0]
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.NAT-instance.primary_network_interface_id
                           #aws_network_interface.private_eni.id
}

