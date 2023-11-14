##################################################################################
# PROVIDERS
##################################################################################
provider "aws" {
    region = var.aws_region
}

#Create DynamoDB table
resource "aws_dynamodb_table" "db_table_name" {
  name = var.db_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}