output "arn" {
  value = aws_dynamodb_table.terraform_dynamodb_table_for_state_locking.arn
  description = "S3 bucket Arn"
}