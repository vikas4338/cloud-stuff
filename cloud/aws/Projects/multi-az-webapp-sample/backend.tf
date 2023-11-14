module "aws_s3_bucket" {
  source = "../../modules/terraform-state-on-s3"
  
  s3_bucket_name        = var.s3_bucket_name
  enable_lifecycle_rule = var.enable_lifecycle_rule
}

module "aws_dynamoDb_table" {
  source = "../../modules/terraform-create-dynamodb-table"
  aws_region = var.aws_region
  db_table_name = var.db_table_name
  billing_mode  = var.billing_mode
  hash_key      = var.hash_key
  attr_name     = var.attr_name
  attr_type     = var.attr_type
}