# variable "environment" {
#   default = "DEV"
#   description = "value"
# }

variable "vpc_public_subnets_cidr_block" {
  type = list(string)
  description = "cidr blocks for public subnets"
  default = [ "10.0.0.0/24", "10.0.1.0/24" ]
}

variable "vpc_cidr_block" {
  type        = string
  description = "Base CIDR Block for VPC"
  default     = "10.0.0.0/16"
}

# -------------------------------------------
# Variables
# -------------------------------------------

variable "aws_region" {
  description = "AWS infrastructure region"
  type        = string
  default     = null
}

variable "s3_bucket_name" {
  description = "s3 bucket names"
  type        = string
  default     = null
}

variable "enable_lifecycle_rule" {
  description = "s3 life cycle"
  type        = bool
  default     = false
}

variable "s3_versioning" {
  description = "s3 versioing"
  type        = string
  default     = "Enabled"
}

# DynamoDB Variables
# -------------------------------------------
variable "db_table_name" {
  description = "DynamoDB table name"
  type        = string
  default     = null
}

variable "billing_mode" {
  description = "DynamoDB billing mode"
  type        = string
  default     = "PAY_PER_REQUEST" # or "PROVISIONED"
}

variable "hash_key" {
  description = "DynamoDB hash kei"
  type        = string
  default     = "LockID"
}

variable "attr_name" {
  description = "DynamoDB attribute name"
  type        = string
  default     = null
}

variable "attr_type" {
  description = "DynamoDB attribute type"
  type        = string
  default     = "S"
}