locals {
  name_prefix  = "${var.app_name}-${var.deploy_env}"
  s3_origin_id = "${local.name_prefix}-s3-origin-id"
}

data "archive_file" "pretty_url_lambda_code" {
  type             = "zip"
  source_file      = "${path.module}/../../pretty-urls/index.js"
  output_file_mode = "0666"
  output_path      = "${path.module}/../../pretty-urls/index.js.zip"
}

resource "aws_s3_bucket" "ks" {
  bucket = "${local.name_prefix}.com"
}

resource "aws_s3_bucket_acl" "ks_acl" {
  bucket = aws_s3_bucket.ks.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "ks_bucket_cf_access" {
  bucket = aws_s3_bucket.ks.id
  policy = jsonencode({
    Version = "2008-10-17"
    Id      = "PolicyForCloudFrontPrivateContent"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject",
        Resource = "${aws_s3_bucket.ks.arn}/*",
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = "${aws_cloudfront_distribution.ks_cf_distribution.arn}"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role" "lambda_edge_exec" {
  name = "${local.name_prefix}-pretty-url"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["lambda.amazonaws.com", "edgelambda.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_lambda_function" "pretty_url_lambda" {
  filename      = "${path.module}/../../pretty-urls/index.js.zip"
  function_name = "${local.name_prefix}-pretty-url-rewriter"
  role          = aws_iam_role.lambda_edge_exec.arn
  handler       = "index.handler"

  source_code_hash = data.archive_file.pretty_url_lambda_code.output_base64sha256

  runtime = "nodejs18.x"

  publish  = true

  provider = aws.us-east-1
}

resource "aws_cloudfront_origin_access_control" "ks_cf_origin_acl" {
  name                              = "${local.name_prefix}-origin"
  description                       = "S3 origin ACL"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "ks_cf_distribution" {
  origin {
    domain_name              = aws_s3_bucket.ks.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.ks_cf_origin_acl.id
    origin_id                = local.s3_origin_id
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = ["keithschulze.com", "www.keithschulze.com"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    lambda_function_association {
      event_type = "origin-request"
      lambda_arn = "${aws_lambda_function.pretty_url_lambda.qualified_arn}"
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/assets/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    lambda_function_association {
      event_type = "origin-request"
      lambda_arn = "${aws_lambda_function.pretty_url_lambda.qualified_arn}"
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    lambda_function_association {
      event_type = "origin-request"
      lambda_arn = "${aws_lambda_function.pretty_url_lambda.qualified_arn}"
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "blacklist"
      locations        = ["RU", "IR", "KP"]
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

resource "aws_route53_zone" "ks_com" {
  name = "keithschulze.com"
}

resource "aws_route53_record" "ks_com" {
  zone_id = aws_route53_zone.ks_com.zone_id
  name    = "keithschulze.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.ks_cf_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.ks_cf_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "www_ks_com" {
  zone_id = aws_route53_zone.ks_com.zone_id
  name    = "www.keithschulze.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.ks_cf_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.ks_cf_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}
