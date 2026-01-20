resource "aws_ssm_document" "session_manager_prefs_doc" {
  name            = "SSM-SessionManagerRunShell"
  document_type   = "Session"
  document_format = "JSON"

  content         = jsonencode({
    schemaVersion = "1.0"
    description   = "Document to hold regional settings for Session Manager"
    sessionType   = "Standard_Stream"
    inputs = {
      s3BucketName          = var.bucket_name
      s3KeyPrefix           = "ssmlogs/"
      s3EncryptionEnabled   = true
     # cloudWatchLogGroupName = aws_cloudwatch_log_group.ec2_session_logs.name
      kmsKeyId              = var.kms_key_id
    }
  })
  
  tags          = var.tags
}


