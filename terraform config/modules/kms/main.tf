# Section for KMS key
resource "aws_kms_key" "credentialKey" {
  description             = "Key for encrypting credentials and securing ssm"
  deletion_window_in_days = var.deletion_days
  enable_key_rotation     = true
  
  #policy = file("modules/json-policy/kms-access-policy.json")
  
  policy = jsonencode(var.policy)

  tags = var.tags
}

# Section for KMS key alias

resource "aws_kms_alias" "credentialKey" {
  name          = "alias/ec2-session"
  target_key_id = aws_kms_key.credentialKey.key_id
}