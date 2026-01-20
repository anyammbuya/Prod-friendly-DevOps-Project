terraform {


  # Terraform Backend Block
  backend "s3" {
    bucket = "jenkinsbackend"
    key    = "dev/terraform.tfstate"
    region = "us-west-2"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.20.0"
    }
  }

  required_version = ">= 1.2"
}


