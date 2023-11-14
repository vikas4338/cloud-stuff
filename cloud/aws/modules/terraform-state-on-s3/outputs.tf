output "arn" {
  value = aws_s3_bucket.terraform_bucket_for_iac.arn
  description = "S3 bucket Arn"
}