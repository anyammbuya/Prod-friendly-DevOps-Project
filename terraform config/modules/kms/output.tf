
output "kms_key_id" {
  description = "arn of kms key"
  value       = aws_kms_key.credentialKey.arn
}

