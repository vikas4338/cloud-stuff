##################################################################################
# PROVIDERS
##################################################################################
provider "aws" {
    region = var.aws_region
}

#Create DynamoDB table
resource "aws_dynamodb_table" "terraform_dynamodb_table_for_state_locking" {
  name = var.dynamodb_table_name_for_locking
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}