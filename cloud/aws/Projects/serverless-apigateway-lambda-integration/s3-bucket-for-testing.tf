resource "random_pet" "testing_bucket" {
  prefix = "test"
  length = 2
}

resource "aws_s3_bucket" "testing_bucket" {
  bucket = random_pet.testing_bucket.id
  force_destroy = true
}

resource "aws_s3_object" "testing_bucket_object" {
  bucket = aws_s3_bucket.testing_bucket.id
  key = "hello.json"
  content = "{\"bucket\":\"${aws_s3_bucket.testing_bucket.id}\",\"object\":\"hello.json\"}"
} 


