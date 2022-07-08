terraform {
#  backend "s3" {
#    bucket = "s3-backend-init-directive-tf-state"
#    key = "s3-backend-init/terraform.tfstate"
#    region  = "us-east-1"
#    dynamodb_table = "terraform-state-locking"
#    encrypt = true
#  }
  required_version = "=1.2.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.21.0"
    }
  }
}

provider "aws" {
  profile = "devops"
  region  = "us-east-1"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket        = "s3-backend-init-directive-tf-state"
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_encryption" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  hash_key     = "LockID"
  name         = "terraform-state-locking"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "LockID"
    type = "S"
  }
}