data "aws_iam_policy_document" "alb_log" {
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.alb_log_bucket.id}/*"]
    principals {
      type        = "AWS"
      identifiers = ["582318560864"]
    }
  }
}

# -----------------------------------------
# Log Bucket for ALB
# -----------------------------------------
resource "aws_s3_bucket" "alb_log_bucket" {
  bucket        = "${var.environment}-alb-log"
  force_destroy = true
}

resource "aws_s3_bucket_lifecycle_configuration" "alb_log_bucket-config" {
  bucket = aws_s3_bucket.alb_log_bucket.id
  rule {
    id     = "logging"
    status = "Enabled"
    expiration {
      days = 180
    }
  }
}

resource "aws_s3_bucket_policy" "alb_log_bucket_policy" {
  bucket = aws_s3_bucket.alb_log_bucket.id
  policy = data.aws_iam_policy_document.alb_log.json
}

# -----------------------------------------
# Log Bucket for CloudFront
# -----------------------------------------
resource "aws_s3_bucket" "cloudfront_log_bucket" {
  bucket        = "${var.environment}-cloudfront-log"
  force_destroy = true
}
