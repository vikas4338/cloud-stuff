resource "aws_lambda_function" "hello" {
  function_name = "hello"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_hello.key

  runtime = "nodejs16.x"
  handler = "function.handler"

  source_code_hash = data.archive_file.lambda_hello.output_base64sha256

  role = aws_iam_role.hello_lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "hello" {
  name = "/aws/lambda/${aws_lambda_function.hello.function_name}"

  retention_in_days = 14
}

data "archive_file" "lambda_hello" {
  type = "zip"

  source_dir  = "./${path.module}/hello"
  output_path = "./${path.module}/hello.zip"
}

resource "aws_s3_object" "lambda_hello" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "hello.zip"
  source = data.archive_file.lambda_hello.output_path

  etag = filemd5(data.archive_file.lambda_hello.output_path)
}

resource "aws_lambda_permission" "api_gw_hello_Lambda" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}

resource "aws_iam_role" "hello_lambda_exec" {
  name = "hello-lambda"

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

resource "aws_iam_policy" "s3_getObjects_policy" {
  name        = "S3-GetObjects-Policy"
  description = "This policy allow access to getObjects action"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": ["${aws_s3_bucket.testing_bucket.arn}"]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "hello_lambda_policy" {
  role       = aws_iam_role.hello_lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole" 
}

resource "aws_iam_role_policy_attachment" "hello_lambda_policy_custom" {
  role       = aws_iam_role.hello_lambda_exec.name
  policy_arn = aws_iam_policy.s3_getObjects_policy.arn
}


#####################################################
#### Lambda function for PetStore
#####################################################

resource "aws_lambda_function" "petStore_lambda" {
  function_name = "petStore"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_petStore.key

  runtime = "nodejs16.x"
  handler = "function.handler"

  source_code_hash = data.archive_file.lambda_petStore.output_base64sha256

  role = aws_iam_role.petStore_lambda_exec.arn
}

data "archive_file" "lambda_petStore" {
  type = "zip"

  source_dir  = "./${path.module}/petStore"
  output_path = "./${path.module}/petStore.zip"
}

resource "aws_s3_object" "lambda_petStore" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "petStore.zip"
  source = data.archive_file.lambda_petStore.output_path

  etag = filemd5(data.archive_file.lambda_petStore.output_path)
}

resource "aws_iam_role" "petStore_lambda_exec" {
  name = "petStore-lambda"

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

resource "aws_iam_role_policy_attachment" "petStore_lambda_policy" {
  role       = aws_iam_role.petStore_lambda_exec.name
  policy_arn = aws_iam_policy.dynamodb_policy.arn 
}

resource "aws_iam_role_policy_attachment" "petStore_lambda_policy_basic" {
  role       = aws_iam_role.petStore_lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole" 
}

resource "aws_iam_policy" "dynamodb_policy" {
  name        = "DynamoDb-Policy"
  description = "This policy allow access dynamo db table from Lambda function"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:*"
      ],
      "Effect": "Allow",
      "Resource": ["${aws_dynamodb_table.pets_store.arn}"]
    }
  ]
}
EOF
}

resource "aws_lambda_permission" "api_gw_petstore_Lambda" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.petStore_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}

resource "aws_cloudwatch_log_group" "petStore" {
  name = "/aws/lambda/${aws_lambda_function.petStore_lambda.function_name}"

  retention_in_days = 14
}