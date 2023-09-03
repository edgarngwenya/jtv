resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
}

resource "aws_s3_bucket" "private_website_bucket" {
  bucket = "${var.environment_name}-cuvama-engineering-private"

  tags = local.common_tags
}

resource "aws_s3_bucket_policy" "private_bucket_policy" {
  bucket = aws_s3_bucket.private_website_bucket.id
  policy = <<EOF
{
"Version": "2008-10-17",
"Statement": [
    {
        "Sid": "2",
        "Effect": "Allow",
        "Principal": {
            "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.origin_access_identity.id}"
        },
        "Action": "s3:GetObject",
        "Resource": "arn:aws:s3:::${var.environment_name}-cuvama-engineering-private/*"
    }
  ]
}
EOF
}

resource "aws_s3_bucket" "public_website_bucket" {
  bucket = "${var.environment_name}-cuvama-engineering-public"

  tags = local.common_tags
}

resource "aws_s3_bucket_policy" "public_bucket_policy" {
  bucket = aws_s3_bucket.public_website_bucket.id
  policy = <<EOF
{
"Version": "2008-10-17",
"Statement": [
    {
        "Sid": "2",
        "Effect": "Allow",
        "Principal": {
            "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.origin_access_identity.id}"
        },
        "Action": "s3:GetObject",
        "Resource": "arn:aws:s3:::${var.environment_name}-cuvama-engineering-public/*"
    }
  ]
}
EOF
}

locals {
  private_s3_origin_id = "private-s3"
  public_s3_origin_id = "public-s3"
}

resource "aws_cloudfront_key_group" "key_group" {
  items   = [var.cloudfront_public_key_id]
  name    = "${var.environment_name}-engineering-key-group"
}

resource "aws_cloudfront_distribution" "distribution" {
  origin {
    domain_name = aws_s3_bucket.private_website_bucket.bucket_regional_domain_name
    origin_id = local.private_s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  origin {
    domain_name = aws_s3_bucket.public_website_bucket.bucket_regional_domain_name
    origin_id = local.public_s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled = true
  aliases = local.cloudfront_host_names

  default_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
      "OPTIONS"]
    cached_methods = [
      "GET",
      "HEAD"]
    target_origin_id = local.public_s3_origin_id
    viewer_protocol_policy = "redirect-to-https"


    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    lambda_function_association {
      event_type = "origin-request"
      lambda_arn = var.lambda_at_edge_arn
    }

    lambda_function_association {
      event_type = "origin-response"
      lambda_arn = var.lambda_at_edge_arn
    }
  }

  ordered_cache_behavior {
    path_pattern     = "/private/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "DELETE", "PATCH", "POST"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.private_s3_origin_id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    //trusted_key_groups = [aws_cloudfront_key_group.key_group.id]

    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    lambda_function_association {
      event_type = "origin-request"
      lambda_arn = var.lambda_at_edge_arn
    }

    lambda_function_association {
      event_type = "origin-response"
      lambda_arn = var.lambda_at_edge_arn
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    minimum_protocol_version = "TLSv1.2_2019"
    acm_certificate_arn = var.cloudfront_certificate_arn
    ssl_support_method = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = local.common_tags
}
