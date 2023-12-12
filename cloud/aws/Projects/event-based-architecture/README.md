# Event Driven Architecture
  An event-driven architecture uses events to trigger and communicate between services. In this project we have used S3, SNS, SQS and Lambda functions. Below architecture diagram shows how the different services are interacting with each other.

# Architecture 
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/116b8e83-9fed-40d4-a13a-f91449c62c08)

- Document upload to S3 triggers S3 notification event and this event is pushed to SNS Topic.
- SQS queues subscribe to the SNS topic. We created some subscription message filters to redirect messages to different queues
  Like "ObjectCreated:Put" should go to specific SQS queue. Below is an example of setting filter policy.
  ![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/6a4f8d01-975a-4ffb-81f1-e958094bea99)
- Lambda functions reads messages from those specific queues and log information to the cloudwatch logs. 

# Provisioning Infrastructure with Terraform 

## Create S3 bucket for Storing object which would trigger event notification
- Generate random number resource 
```terraform
resource "random_integer" "random_int_for_s3_bucket" {
  min = 1
  max = 10
}
```

- create s3 bucket
```terraform
resource "aws_s3_bucket" "bucket_as_event_source" {
  bucket        = "bucket-event-source-${random_integer.random_int_for_s3_bucket.id}"
  force_destroy = true
}
```
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/a4c5760b-7858-401b-8aea-fd0da4f70db9)


- Create s3 notification and push to SNS topic (SNS topic created below)
```terraform
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket_as_event_source.id

  topic {
    topic_arn = aws_sns_topic.sns_topic_for_s3_upload_updates.arn
    events    = ["s3:ObjectCreated:*"]
  }
}
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/2ae69210-13dd-428c-aa61-6bce550d34a8)

![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/cf02a0fc-5218-4794-a86d-ed689262397c)

```

### Create SNS topic which receives notifications about s3 upload event
```terraform
  resource "aws_sns_topic" "sns_topic_for_s3_upload_updates" {
    name = "s3-event-notification-topic"
  }
```
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/254e23f7-6a66-48c1-829d-1f26296bb393)


- Create SNS topic policy resource to allow S3 to push notification to SNS topic and allow SQS to subscribe to topic 
  ```terraform
    // Get the AWS account information
    data "aws_caller_identity" "current" {}

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
  ```
  ![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/53204a7c-01bb-40f1-8086-28202e9e582c)


- SQS (for PUT events) Subscription to the SNS topic, please note eventName ('ObjectCreated:Put') in filter policy, this filter policy helps in pushing the PUT events to the respective queue
```terraform
  resource "aws_sns_topic_subscription" "s3_updates_subscription_put_events" {
    topic_arn = aws_sns_topic.sns_topic_for_s3_upload_updates.arn
    protocol  = "sqs"
    endpoint  = aws_sqs_queue.queue_for_processing_put_events_on_s3.arn
    filter_policy_scope = "MessageBody"
    filter_policy = "{\"Records\":{\"eventName\":[\"ObjectCreated:Put\"]}}"
    raw_message_delivery = true
  }
```
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/35a66460-99e0-4f56-99d1-61e077f885c5)
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/6b21bb75-e16d-480a-89a7-f9ecf7e7fd57)

- SQS (for COPY events) Subscription to the SNS topic, please note eventName ('ObjectCreated:Copy') in filter policy, this filter policy helps in pushing the COPY events to the respective queue
```terraform
  resource "aws_sns_topic_subscription" "s3_updates_subscription_copy_events" {
    topic_arn = aws_sns_topic.sns_topic_for_s3_upload_updates.arn
    protocol  = "sqs"
    endpoint  = aws_sqs_queue.queue_for_processing_copy_events_on_s3.arn
    filter_policy_scope = "MessageBody"
    filter_policy = "{\"Records\":{\"eventName\":[\"ObjectCreated:Copy\"]}}"
    raw_message_delivery = true
  }
```
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/cbaeb901-1646-449a-9467-378e0d42efa7)
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/ce339c5e-7cad-4f59-aa7b-4ee2882615ec)


- This policy allows SNS topic to push messages to the Queue (**PUT events**) and allows lambda to read messages from the Queue. Note - We added a SQS trigger to lambda function so as soon as messages goes to 
   SQS, then lambda      read that message for processing
  ```terraform
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
  ```
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/3623958a-3c8a-4a19-8feb-4ef219f84a41)


- Create SQS queue for "COPY" notification messages from S3 
  ```terraform
  resource "aws_sqs_queue" "queue_for_processing_copy_events_on_s3" {
    name                      = "queue-for-processing-copy-events-on-s3"
    delay_seconds             = 90
    max_message_size          = 2048
    message_retention_seconds = 86400
    receive_wait_time_seconds = 10
  }
  ```
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/82f7689d-4a46-48ec-bb65-a33ed40850bf)

  
- This policy allows SNS topic to push messages to the Queue (**COPY events**) and allows lambda to read messages from the Queue. Note - We added a SQS trigger to lambda function so as soon as messages goes to 
   SQS, then lambda read that message for processing
  ```terraform
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
  ```
  ![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/27cab798-2c09-4800-a97f-98e4b7e1d854)


  ### The last layer is the lambda (can be seen in the design) which reads messages from respective queues. Lets provision them 

  - S3 bucket for storing lambda code
  ```terraform
    resource "random_integer" "lambda_bucket_name" {
      min = 1
      max = 1000
    }
  
    resource "aws_s3_bucket" "lambda_bucket" {
      bucket        = "bucket-for-lambda-source-code-${random_integer.lambda_bucket_name.id}"
      force_destroy = true
    }
  ```
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/0732a00d-2dff-401a-9469-f827c7c2a683)


- Lambda function for handling PUT events

  ```terraform
  resource "aws_lambda_function" "put_event_processor" {
    function_name = "put-event-processor"
  
    s3_bucket = aws_s3_bucket.lambda_bucket.id
    s3_key    = aws_s3_object.put_event_processor_object.key
  
    runtime = "nodejs16.x"
    handler = "function.handler"
  
    source_code_hash = data.archive_file.put_event_processor_lambda_archive.output_base64sha256
  
    role = aws_iam_role.put_event_processor_lambda_exec.arn
  }
  ```
  ![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/ac3262e9-e75c-4ab0-b4f8-8fe5934aa95a)

- Create log group for lambda function
  ```terraform
  resource "aws_cloudwatch_log_group" "put_event_processor_lambda_log_grp" {
    name = "/aws/lambda/${aws_lambda_function.put_event_processor.function_name}"
  
    retention_in_days = 14
  }
  ```
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/b4c13ae6-b843-4879-8b57-494c2d6abfb8)


  - Create zip file and copy that to S3 bucket
  ```terraform
  data "archive_file" "put_event_processor_lambda_archive" {
    type = "zip"
  
    source_dir  = "./${path.module}/putEventProcessor"
    output_path = "./${path.module}/putEventProcessor.zip"
  }

  resource "aws_s3_object" "put_event_processor_object" {
    bucket = aws_s3_bucket.lambda_bucket.id
  
    key    = "putEventProcessor.zip"
    source = data.archive_file.put_event_processor_lambda_archive.output_path
  
    etag = filemd5(data.archive_file.put_event_processor_lambda_archive.output_path)
  }
  ```

- Create iam role for putEvent processor lambda and attach required policies (AWSLambdaBasicExecutionRole, allow interacting with queu and logs)
  ```terraform
  resource "aws_iam_role" "put_event_processor_lambda_exec" {
    name = "putEvent-processor-lambda-exec-role"
  
    assume_role_policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  POLICY
  }
  
  resource "aws_iam_policy" "access_policies_for_putEventprocessor_lambda_function" {
    name        = "access-policies-for-putEventprocessor-lambda-function"
    description = "This policy allow required access to lambda function"
  
    policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
          {
              "Sid": "sid1",
              "Effect": "Allow",
              "Action": [
                  "sqs:DeleteMessage",
                  "sqs:ReceiveMessage",
                  "sqs:GetQueueAttributes",
                  "logs:CreateLogStream",
                  "logs:PutLogEvents"
              ],
              "Resource": [
                  "${aws_sqs_queue.queue_for_processing_put_events_on_s3.arn}",
                  "${aws_cloudwatch_log_group.put_event_processor_lambda_log_grp.arn}"
              ]
          },
          {
              "Sid": "sid2",
              "Effect": "Allow",
              "Action": [
                  "sqs:ReceiveMessage",
                  "logs:CreateLogGroup"
              ],
              "Resource": [
                  "${aws_sqs_queue.queue_for_processing_put_events_on_s3.arn}"
              ]
          }
      ]
  }
  EOF
  }
  
  resource "aws_iam_role_policy_attachment" "policy_for_putEventProcessor_lambda" {
    role       = aws_iam_role.put_event_processor_lambda_exec.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  }
  
  resource "aws_iam_role_policy_attachment" "custom_policy_for_put_event_processor_lambda" {
    role       = aws_iam_role.put_event_processor_lambda_exec.name
    policy_arn = aws_iam_policy.access_policies_for_putEventprocessor_lambda_function.arn
  }
  ```
  ![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/a7c8b2b3-34f7-47fb-aaeb-46b6df1ff1bc)
  ![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/4741a180-c3e2-4091-b798-c0f0870c4ed4)

  
  - Add SQS as lambda trigger
  ```terraform
  resource "aws_lambda_event_source_mapping" "event_source_mapping_for_put_events" {
    event_source_arn = aws_sqs_queue.queue_for_processing_put_events_on_s3.arn
    enabled = true
    function_name = aws_lambda_function.put_event_processor.function_name
    batch_size = 1
  }
  ```

  - Lambda function for handling copy events
  ```terraform
  resource "aws_lambda_function" "copy_event_processor" {
    function_name = "copy-event-processor"
  
    s3_bucket = aws_s3_bucket.lambda_bucket.id
    s3_key    = aws_s3_object.copy_event_processor_object.key
  
    runtime = "nodejs16.x"
    handler = "function.handler"
  
    source_code_hash = data.archive_file.copy_event_processor_lambda_archive.output_base64sha256
  
    role = aws_iam_role.copy_event_processor_lambda_exec.arn
  }
  ```
  ![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/30d86939-c7f8-4184-aa3f-11a6de4044a6)


  - Create cloudwatch group
  ```terraform
  resource "aws_cloudwatch_log_group" "copy_event_processor_lambda_log_grp" {
    name = "/aws/lambda/${aws_lambda_function.copy_event_processor.function_name}"
  
    retention_in_days = 14
  }
  ```
  ![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/0ae64dda-88cd-499e-8b2d-789b104fa2c6)

  - Create zip file and copy that to s3 bucket

  ```terraform
  data "archive_file" "copy_event_processor_lambda_archive" {
    type = "zip"
  
    source_dir  = "./${path.module}/copyEventProcessor"
    output_path = "./${path.module}/copyEventProcessor.zip"
  }
  
  resource "aws_s3_object" "copy_event_processor_object" {
    bucket = aws_s3_bucket.lambda_bucket.id
  
    key    = "copyEventProcessor.zip"
    source = data.archive_file.copy_event_processor_lambda_archive.output_path
  
    etag = filemd5(data.archive_file.copy_event_processor_lambda_archive.output_path)
  }
  ```

  - Create iam role for copyEvent processor lambda and attach required policies
  ```terraform
  resource "aws_iam_role" "copy_event_processor_lambda_exec" {
    name = "copyEvent-processor-lambda-exec-role"
  
    assume_role_policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  POLICY
  }
  
  resource "aws_iam_policy" "access_policies_for_copyEventprocessor_lambda_function" {
    name        = "access-policies-for-copyEventprocessor-lambda-function"
    description = "This policy allow required access to lambda function"
  
    policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
          {
              "Sid": "sid1",
              "Effect": "Allow",
              "Action": [
                  "sqs:DeleteMessage",
                  "sqs:ReceiveMessage",
                  "sqs:GetQueueAttributes",
                  "logs:CreateLogStream",
                  "logs:PutLogEvents"
              ],
              "Resource": [
                  "${aws_sqs_queue.queue_for_processing_copy_events_on_s3.arn}",
                  "${aws_cloudwatch_log_group.copy_event_processor_lambda_log_grp.arn}"
              ]
          },
          {
              "Sid": "sid2",
              "Effect": "Allow",
              "Action": [
                  "sqs:ReceiveMessage",
                  "logs:CreateLogGroup"
              ],
              "Resource": [
                  "${aws_sqs_queue.queue_for_processing_copy_events_on_s3.arn}"
              ]
          }
      ]
  }
  EOF
  }
  
  resource "aws_iam_role_policy_attachment" "policy_for_copyEventProcessor_lambda" {
    role       = aws_iam_role.copy_event_processor_lambda_exec.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  }
  
  resource "aws_iam_role_policy_attachment" "custom_policy_for_copy_event_processor_lambda" {
    role       = aws_iam_role.copy_event_processor_lambda_exec.name
    policy_arn = aws_iam_policy.access_policies_for_copyEventprocessor_lambda_function.arn
  }
  ```
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/7fca6943-5285-4042-949e-ce3d52f8881a)
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/25eb23e6-bd0e-47bd-a820-b6aae2819b65)

- Add SQS as lambda trigger
  ```terraform
  resource "aws_lambda_event_source_mapping" "event_source_mapping_for_copy_events" {
    event_source_arn = aws_sqs_queue.queue_for_processing_copy_events_on_s3.arn
    enabled = true
    function_name = aws_lambda_function.copy_event_processor.function_name
    batch_size = 1
  }
  ```

### Terraform commands for running workflow
- terraform plan -var region="us-east-1"
- terraform apply -var region="us-east-1" --auto-approve

**Finally, dont forget to clean resources**
- terraform destroy -var region="us-east-1" --auto-approve 

# Running the workflow
### PUT Event - Upload an image to S3
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/2c5c7ef9-4b1c-4106-85f3-717cb6b92d89)

- See the Cloudwatch logs for information regarding event
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/8c5b938d-ffb9-4fcc-b41f-288fb29a31db)

### COPY Event - Copy Image from/to same bucket
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/a76ecd37-1633-489a-9b52-fe30d49014c1)

- See the Cloudwatch logs for information regarding event
![image](https://github.com/vikas4338/cloud-stuff/assets/13362154/37b21abd-5d32-40b4-89a1-3fe1a9350b2c)

  
