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