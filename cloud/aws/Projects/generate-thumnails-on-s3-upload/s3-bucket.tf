resource "random_pet" "random_string_for_s3_bucket" {
  prefix = "lambda"
  length = 2
}

resource "aws_s3_bucket" "s3_bucket_for_lambda_function" {
  bucket = random_pet.random_string_for_s3_bucket.id
  force_destroy = true
}

resource "aws_s3_bucket" "s3_bucket_for_images" {
  bucket = "s3-bucket-for-images-11078"
  force_destroy = true
}
