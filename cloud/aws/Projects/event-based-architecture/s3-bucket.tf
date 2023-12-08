resource "random_integer" "random_int_for_s3_bucket" {
  min = 1
  max = 10
}

resource "aws_s3_bucket" "bucket_as_event_source" {
  bucket        = "bucket-event-source-${random_integer.random_int_for_s3_bucket.id}"
  force_destroy = true
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket_as_event_source.id

  topic {
    topic_arn = aws_sns_topic.sns_topic_for_s3_upload_updates.arn
    events    = ["s3:ObjectCreated:*"]
  }
}