// s3 bucket for storing mp3 files after conversion
resource "aws_s3_bucket" "bucket_for_mp3_files" {
  bucket        = "bucket-for-mp3-files"
  force_destroy = true
}