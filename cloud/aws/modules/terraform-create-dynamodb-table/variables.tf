# -------------------------------------------
# Variables
# -------------------------------------------

variable "aws_region" {
  description = "AWS infrastructure region"
  type        = string
}

variable "dynamodb_table_name_for_locking" {
  description = "dynamodb table name"
  type        = string
}
