resource "aws_lambda_function" "lambda_function_for_thumnail_generation" {
  function_name = "thumnail-generator"

  s3_bucket = aws_s3_bucket.s3_bucket_for_lambda_function.id
  s3_key    = aws_s3_object.s3_object_for_lambda_code.key

  runtime = "python3.9"
  handler = "function.lambda_handler"

  source_code_hash = data.archive_file.lambda_thumnail_generator.output_base64sha256

  role = aws_iam_role.thumbnail_generator_exec.arn
}

data "archive_file" "lambda_thumnail_generator" {
  type = "zip"

  source_dir  = "./${path.module}/thumbnail-generator"
  output_path = "./${path.module}/thumbnail-generator.zip"
}

resource "aws_cloudwatch_log_group" "thumbnail-generator" {
  name = "/aws/lambda/${aws_lambda_function.lambda_function_for_thumnail_generation.function_name}"

  retention_in_days = 14
}

resource "aws_iam_role" "thumbnail_generator_exec" {
  name = "thumbnail-generator"

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

resource "aws_iam_policy" "s3_custom_policy" {
  name        = "S3-Policy-for-thumbmail-generation"
  description = "This policy allow access to getObject and putobject action"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": ["${aws_s3_bucket.s3_bucket_for_images.arn}"]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "iam_policy_for_thumnail_generation" {
  role       = aws_iam_role.thumbnail_generator_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole" 
}

resource "aws_iam_role_policy_attachment" "iam_policy_for_thumnail_generation_custom" {
  role       = aws_iam_role.thumbnail_generator_exec.name
  policy_arn = aws_iam_policy.s3_custom_policy.arn
}

resource "aws_s3_object" "s3_object_for_lambda_code" {
  bucket = aws_s3_bucket.s3_bucket_for_lambda_function.id

  key    = "thumbnail-generator.zip"
  source = data.archive_file.lambda_thumnail_generator.output_path

  etag = filemd5(data.archive_file.lambda_thumnail_generator.output_path)
}

resource "aws_s3_object" "s3_object_for_imaging_bucket" {
  bucket = aws_s3_bucket.s3_bucket_for_images.id

  key    = "sample.jpg"
  source = "${path.module}/assets/sample.jpg"

  etag = "${filemd5("${path.module}/assets/sample.jpg")}"
}