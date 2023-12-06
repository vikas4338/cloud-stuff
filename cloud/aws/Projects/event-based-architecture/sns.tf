// Create SNS Topic
resource "aws_sns_topic" "sns_topic_for_s3_upload_updates" {
  name = "s3-event-notification-topic"
}

// SNS policy to allow 
// - S3 to push notification to S3
// - SQS to subscibe the topic 
resource "aws_sns_topic_policy" "default" {
  arn    = aws_sns_topic.sns_topic_for_s3_upload_updates.arn
  
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
          "aws:SourceAccount": "604553012726"
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
          "aws:SourceArn": "${aws_sqs_queue.sqs_queue_for_s3_updates.arn}"
        }
      }
    }
  ]
}
EOF
}


// SQS Subscription to the SNS topic
resource "aws_sns_topic_subscription" "s3_updates_subscription" {
  topic_arn = aws_sns_topic.sns_topic_for_s3_upload_updates.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.sqs_queue_for_s3_updates.arn
}
