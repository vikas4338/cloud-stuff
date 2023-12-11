resource "aws_s3_bucket" "s3_bucket_for_hosting_resume" {
  bucket = "resume.vikaskumar.net"
  
  force_destroy = true
}

resource "aws_s3_bucket_cors_configuration" "s3_bucket_cors_configurations" {
  bucket = aws_s3_bucket.s3_bucket_for_hosting_resume.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
  }
}

locals {
  content_types = {
    ".html" : "text/html",
    ".css" : "text/css",
    ".js" : "text/javascript"
  }
}

resource "aws_s3_object" "copy_resume_content_to_s3_hosting_bucket" {
  for_each     = fileset(path.module, "resume/**/*.{html,css,js}")
  bucket       = aws_s3_bucket.s3_bucket_for_hosting_resume.id
  key          = replace(trimprefix(each.value, "resume/"), "/^content//", "")
  source       = each.value
  content_type = lookup(local.content_types, regex("\\.[^.]+$", each.value), null)
  etag         = filemd5(each.value)
}

resource "aws_s3_bucket_website_configuration" "aws_Static_website_config" {
  bucket = aws_s3_bucket.s3_bucket_for_hosting_resume.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.s3_bucket_for_hosting_resume.id
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "AllowCloudFrontServicePrincipalReadOnly",
          "Effect" : "Allow",
           "Principal": {
                "Service": "cloudfront.amazonaws.com"
            },
          "Action" : "s3:*",
          "Resource" : "arn:aws:s3:::${aws_s3_bucket.s3_bucket_for_hosting_resume.id}/*"
          "Condition": {
            "StringEquals": {
                "AWS:SourceArn": "${aws_cloudfront_distribution.distribution.arn}"
            }
          }
        }
      ]
    }
  )
}

// Cloudfront distribution for static website
resource "aws_cloudfront_distribution" "distribution" {
  enabled         = true
  is_ipv6_enabled = true

  origin {
    domain_name = aws_s3_bucket_website_configuration.aws_Static_website_config.website_endpoint
    origin_id   = aws_s3_bucket.s3_bucket_for_hosting_resume.bucket_regional_domain_name

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = 30
      origin_ssl_protocols = [
        "TLSv1.2",
      ]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  default_cache_behavior {
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.s3_bucket_for_hosting_resume.bucket_regional_domain_name
  }
}

output "website_url" {
  description = "Website URL (HTTPS)"
  value       = aws_cloudfront_distribution.distribution.domain_name
}

output "s3_url" {
  description = "S3 hosting URL (HTTP)"
  value       = aws_s3_bucket_website_configuration.aws_Static_website_config.website_endpoint
}