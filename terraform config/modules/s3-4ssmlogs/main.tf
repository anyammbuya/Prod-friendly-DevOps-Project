# Create the S3 bucket

resource "aws_s3_bucket" "ec2ssm-logs-bucket" {
  
  bucket        = "zeus-ec2ssm-logsbu"
  force_destroy = true
  tags          = var.tags
}
resource "aws_s3_bucket_ownership_controls" "ec2ssm-logs-bucket" {
  bucket = aws_s3_bucket.ec2ssm-logs-bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "ec2ssm-logs-bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.ec2ssm-logs-bucket]

  bucket = aws_s3_bucket.ec2ssm-logs-bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "ec2ssm-logs-bucket" {
  bucket = aws_s3_bucket.ec2ssm-logs-bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ec2ssm-logs-bucket" {
  bucket = aws_s3_bucket.ec2ssm-logs-bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_id
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled  =true
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "ec2ssm-logs-bucket" {
  bucket = aws_s3_bucket.ec2ssm-logs-bucket.id

  rule {
    id     = "archive_ssm_logs"
    status = "Enabled"

    filter {
      prefix = "ssmlogs/"
    }

    transition {
      days          = var.log_archive_days
      storage_class = "GLACIER"
    }

    expiration {
      days = var.log_expire_days
    }
  }

  # New rule for artifacts - different retention policy
  rule {
    id     = "artifact_retention"
    status = "Enabled"

    filter {
      prefix = "artifacts/"
    }

    transition {
      days          = 90  # Move to Glacier after 90 days
      storage_class = "GLACIER"
    }

    expiration {
      days = 180
    } 
  }
}

resource "aws_s3_bucket_public_access_block" "ec2ssm-logs-bucket" {
  bucket                  = aws_s3_bucket.ec2ssm-logs-bucket.id
  block_public_acls       = true    # block new acls that allow public access
  block_public_policy     = true    # block bucket policy that allow public access
  ignore_public_acls      = true    # ignore existing acls that have been allowing pu access
  restrict_public_buckets = true    #
}


/*
resource "aws_s3_object" "bucket_prefixes" {
  bucket = aws_s3_bucket.ec2ssm-logs-bucket.id
  key    = "ssmlogs/"  # Trailing slash makes it a folder
}
*/
resource "aws_s3_object" "bucket_prefixes" {
  for_each = toset(["ssmlogs/" , "artifacts/"])
  bucket   = aws_s3_bucket.ec2ssm-logs-bucket.id
  key      = each.key
}