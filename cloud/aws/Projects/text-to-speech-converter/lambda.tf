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
resource "aws_lambda_function" "text_to_speech_converter" {
  function_name = "text-to-speech-converter"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.text_to_speech_converter_object.key

  runtime = "python3.9"
  handler = "lambda_function.lambda_handler"

  source_code_hash = data.archive_file.text_to_speech_converter_lambda_archive.output_base64sha256

  role = aws_iam_role.text_to_speech_converter_lambda_exec.arn
  timeout = 30
}

resource "aws_cloudwatch_log_group" "text_to_speech_converter_lambda_log_grp" {
  name = "/aws/lambda/${aws_lambda_function.text_to_speech_converter.function_name}"

  retention_in_days = 14
}

data "archive_file" "text_to_speech_converter_lambda_archive" {
  type = "zip"

  source_dir  = "./${path.module}/textToSpeech"
  output_path = "./${path.module}/textToSpeech.zip"
}

resource "aws_s3_object" "text_to_speech_converter_object" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "text-to-speech.zip"
  source = data.archive_file.text_to_speech_converter_lambda_archive.output_path

  etag = filemd5(data.archive_file.text_to_speech_converter_lambda_archive.output_path)
}

// Create iam role for putEvent processor lambda and attach required policies
resource "aws_iam_role" "text_to_speech_converter_lambda_exec" {
  name = "text_to_speech_converter-lambda-exec-role"

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

resource "aws_iam_role_policy_attachment" "lambda_basic_exec_role" {
  role       = aws_iam_role.text_to_speech_converter_lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "s3_access_policy" {
  role       = aws_iam_role.text_to_speech_converter_lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "polly_access_policy" {
  role       = aws_iam_role.text_to_speech_converter_lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonPollyFullAccess"
}