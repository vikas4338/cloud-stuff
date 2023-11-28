resource "aws_lambda_function" "lambda_function_for_thumnail_generation" {
  function_name = "thumnail-generator"

  s3_bucket = aws_s3_bucket.s3_bucket_for_lambda_function.id
  s3_key    = aws_s3_object.s3_object_for_lambda_code.key

  runtime = "nodejs16.x"
  handler = "function.handler"

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

resource "aws_s3_object" "s3_object_for_lambda_code" {
  bucket = aws_s3_bucket.s3_bucket_for_lambda_function.id

  key    = "thumbnail-generator.zip"
  source = data.archive_file.lambda_thumnail_generator.output_path

  etag = filemd5(data.archive_file.lambda_thumnail_generator.output_path)
}

resource "aws_s3_object" "s3_object_for_imaging_bucket" {
  bucket = aws_s3_bucket.source_bucket_for_images.id

  key    = "sample.jpg"
  source = "${path.module}/assets/sample.jpg"

  etag = "${filemd5("${path.module}/assets/sample.jpg")}"
}