// S3 bucket for storing lambda code
resource "random_integer" "lambda_bucket_name" {
  min = 1
  max = 1000
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket        = "bucket-for-lambda-source-code-${random_integer.lambda_bucket_name.id}"
  force_destroy = true
}

// Lambda function for handling PUT events
resource "aws_lambda_function" "put_event_processor" {
  function_name = "put-event-processor"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.put_event_processor_object.key

  runtime = "nodejs16.x"
  handler = "function.handler"

  source_code_hash = data.archive_file.put_event_processor_lambda_archive.output_base64sha256

  role = aws_iam_role.put_event_processor_lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "put_event_processor_lambda_log_grp" {
  name = "/aws/lambda/${aws_lambda_function.put_event_processor.function_name}"

  retention_in_days = 14
}

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

// Create iam role for putEvent processor lambda and attach required policies
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

// Add SQS as lambda trigger
resource "aws_lambda_event_source_mapping" "event_source_mapping_for_put_events" {
  event_source_arn = aws_sqs_queue.queue_for_processing_put_events_on_s3.arn
  enabled = true
  function_name = aws_lambda_function.put_event_processor.function_name
  batch_size = 1
}

// Lambda function for handling copy events
resource "aws_lambda_function" "copy_event_processor" {
  function_name = "copy-event-processor"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.copy_event_processor_object.key

  runtime = "nodejs16.x"
  handler = "function.handler"

  source_code_hash = data.archive_file.copy_event_processor_lambda_archive.output_base64sha256

  role = aws_iam_role.copy_event_processor_lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "copy_event_processor_lambda_log_grp" {
  name = "/aws/lambda/${aws_lambda_function.copy_event_processor.function_name}"

  retention_in_days = 14
}

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

// Create iam role for copyEvent processor lambda and attach required policies
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

// Add SQS as lambda trigger
resource "aws_lambda_event_source_mapping" "event_source_mapping_for_copy_events" {
  event_source_arn = aws_sqs_queue.queue_for_processing_copy_events_on_s3.arn
  enabled = true
  function_name = aws_lambda_function.copy_event_processor.function_name
  batch_size = 1
}