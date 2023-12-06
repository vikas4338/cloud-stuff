// Create SQS queue for notification messages from S3 
resource "aws_sqs_queue" "sqs_queue_for_s3_updates" {
  name                      = "queue_for_s3_updates"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
}

// SQS policy to allow 
// - Allow SNS topic to push messages to the queue
// -  
resource "aws_sqs_queue_policy" "sqs_policy" {
  queue_url =  aws_sqs_queue.sqs_queue_for_s3_updates.id

  policy = <<EOF
{
  "Version": "2008-10-17",
  "Id": "__default_policy",
  "Statement":  [
    {
      "Sid": "StmtId_SQS",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.sqs_queue_for_s3_updates.arn}",
      "Condition": {
        "ArnLike": {
          "aws:SourceArn": "${aws_sns_topic.sns_topic_for_s3_upload_updates.arn}"
        }
      }
    }
  ]
}
EOF
}