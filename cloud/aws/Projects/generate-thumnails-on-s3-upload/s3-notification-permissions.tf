resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.source_bucket_for_images.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_function_for_thumnail_generation.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_function.lambda_function_for_thumnail_generation]
}

resource "aws_lambda_permission" "test" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function_for_thumnail_generation.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${aws_s3_bucket.source_bucket_for_images.id}"
}