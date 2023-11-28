// Random name for bucket
resource "random_pet" "random_string_for_s3_bucket" {
  prefix = "lambda"
  length = 2
}

// S3 bucket for storing Lambda code zip file
resource "aws_s3_bucket" "s3_bucket_for_lambda_function" {
  bucket = random_pet.random_string_for_s3_bucket.id
  force_destroy = true
}

// S3 bucket - source for triggering events which will trigger lambda function
resource "aws_s3_bucket" "source_bucket_for_images" {
  bucket = "source-bucket-for-images-11078"
  force_destroy = true
}

// S3 bucket - destination bucket for storing thumbnails
resource "aws_s3_bucket" "destination_bucket_for_thumbnail" {
  bucket = "destination-bucket-for-thumbnails-11078"
  force_destroy = true
}
