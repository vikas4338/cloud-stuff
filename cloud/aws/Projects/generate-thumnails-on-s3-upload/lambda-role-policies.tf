resource "aws_iam_role" "thumbnail_generator_exec" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "s3_custom_policy" {
  name        = "S3-Policy-for-thumbmail-generation"
  description = "This policy allow access to s3 actions"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*",
        "lambda:InvokeFunction"
      ],
      "Effect": "Allow",
      "Resource": ["${aws_lambda_function.lambda_function_for_thumnail_generation.arn}"],
      "Condition": {
      "ArnLike": {
        "AWS:SourceArn": "${aws_s3_bucket.source_bucket_for_images.arn}"
      }
    }
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