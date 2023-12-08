// Create SNS Topic
resource "aws_sns_topic" "sns_topic_for_s3_upload_updates" {
  name = "s3-event-notification-topic"
}

// Get the AWS account information
data "aws_caller_identity" "current" {}

// SNS policy to allow 
// - S3 to push notification to S3
// - SQS to subscibe the topic 
resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.sns_topic_for_s3_upload_updates.arn

  policy = <<EOF
{
  "Version": "2008-10-17",
  "Id": "__default_policy_ID",
  "Statement": [
    {
      "Sid": "__default_statement_ID",
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Action": "SNS:Publish",
      "Resource": "${aws_sns_topic.sns_topic_for_s3_upload_updates.arn}",
      "Condition": {
        "StringEquals": {
          "aws:SourceAccount": "${data.aws_caller_identity.current.account_id}"
        },
        "ArnLike": {
          "aws:SourceArn": "${aws_s3_bucket.bucket_as_event_source.arn}"
        }
      }
    },
    {
      "Sid": "sqs_statement",
      "Effect": "Allow",
      "Principal": {
        "Service": "sqs.amazonaws.com"
      },
      "Action": "sns:Subscribe",
      "Resource": "${aws_sns_topic.sns_topic_for_s3_upload_updates.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": [
            "${aws_sqs_queue.queue_for_processing_put_events_on_s3.arn}",
            "${aws_sqs_queue.queue_for_processing_copy_events_on_s3.arn}"
          ]
        }
      }
    }
  ]
}
EOF
}

// SQS (for PUT events) Subscription to the SNS topic
resource "aws_sns_topic_subscription" "s3_updates_subscription_put_events" {
  topic_arn = aws_sns_topic.sns_topic_for_s3_upload_updates.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.queue_for_processing_put_events_on_s3.arn
  filter_policy_scope = "MessageBody"
  filter_policy = "{\"Records\":{\"eventName\":[\"ObjectCreated:Put\"]}}"
  raw_message_delivery = true
}

// SQS (for COPY events) Subscription to the SNS topic
resource "aws_sns_topic_subscription" "s3_updates_subscription_copy_events" {
  topic_arn = aws_sns_topic.sns_topic_for_s3_upload_updates.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.queue_for_processing_copy_events_on_s3.arn
  filter_policy_scope = "MessageBody"
  filter_policy = "{\"Records\":{\"eventName\":[\"ObjectCreated:Copy\"]}}"
  raw_message_delivery = true
}