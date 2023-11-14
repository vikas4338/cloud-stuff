##################################################################################
# PROVIDERS
##################################################################################
provider "aws" {
    region = var.aws_region
}

#Create s3
resource "aws_s3_bucket" "terraform_bucket_for_iac" {
  bucket = var.s3_bucket_name

  force_destroy = true
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.terraform_bucket_for_iac.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption_configuration" {
  bucket = aws_s3_bucket.terraform_bucket_for_iac.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#Create DynamoDB table
resource "aws_dynamodb_table" "terraform_dynamodb_table_for_state_locking" {
  name = "state.lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}