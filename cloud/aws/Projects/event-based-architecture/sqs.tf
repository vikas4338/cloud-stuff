// Create SQS queue for "PUT" notification messages from S3 
resource "aws_sqs_queue" "queue_for_processing_put_events_on_s3" {
  name                      = "queue-for-processing-put-events-on-s3"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
}

// SQS policy to allow 
// - Allow SNS topic to push messages to the queue
// -  
resource "aws_sqs_queue_policy" "sqs_policy_put-events" {
  queue_url = aws_sqs_queue.queue_for_processing_put_events_on_s3.id

  policy = <<EOF
{
  "Version": "2008-10-17",
  "Id": "__default_policy",
  "Statement":  [
    {
      "Sid": "sid1",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.queue_for_processing_put_events_on_s3.arn}",
      "Condition": {
        "ArnLike": {
          "aws:SourceArn": "${aws_sns_topic.sns_topic_for_s3_upload_updates.arn}"
        }
      }
    },
    {
      "Sid": "sid2",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": [
        "sqs:ReceiveMessage",
        "sqs:sendMessage"
      ],
      "Resource": "${aws_sqs_queue.queue_for_processing_put_events_on_s3.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_lambda_function.put_event_processor.arn}"
        }
      }
    }
  ]
}
EOF
}

// Create SQS queue for "COPY" notification messages from S3 
resource "aws_sqs_queue" "queue_for_processing_copy_events_on_s3" {
  name                      = "queue-for-processing-copy-events-on-s3"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
}

// SQS policy to allow 
// - Allow SNS topic to push messages to the queue
// -  
resource "aws_sqs_queue_policy" "sqs_policy_copy-events" {
  queue_url = aws_sqs_queue.queue_for_processing_copy_events_on_s3.id

  policy = <<EOF
{
  "Version": "2008-10-17",
  "Id": "__default_policy",
  "Statement":  [
    {
      "Sid": "sid1",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.queue_for_processing_copy_events_on_s3.arn}",
      "Condition": {
        "ArnLike": {
          "aws:SourceArn": "${aws_sns_topic.sns_topic_for_s3_upload_updates.arn}"
        }
      }
    },
    {
      "Sid": "sid2",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": [
        "sqs:ReceiveMessage",
        "sqs:sendMessage"
      ],
      "Resource": "${aws_sqs_queue.queue_for_processing_copy_events_on_s3.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_lambda_function.put_event_processor.arn}"
        }
      }
    }
  ]
}
EOF
}