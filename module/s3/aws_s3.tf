resource "random_string" "s3_unique_key" {
  length  = 6
  upper   = false
  lower   = true
  number  = true
  special = false
}

resource "aws_s3_bucket" "aws_logs_bucket" {
  bucket = "${var.project}-${var.env}-aws-logs-${random_string.s3_unique_key.result}"
}

resource "aws_s3_bucket_acl" "aws_logs_bucket_acl" {
  bucket = aws_s3_bucket.aws_logs_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "aws_logs_bucket_policy" {
  bucket = aws_s3_bucket.aws_logs_bucket.id
  policy = templatefile("../../module/s3/bucket_policy/lb_policy.tpl.json",
    {
      bucket_name = aws_s3_bucket.aws_logs_bucket.id,
      account_id  = "${var.current_id}"
    }
  )
}

resource "aws_s3_bucket_versioning" "aws_logs_bucket_versioning" {
  bucket = aws_s3_bucket.aws_logs_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "lb_logs" {
  bucket = aws_s3_bucket.aws_logs_bucket.id
  rule {
    id     = "expire"
    status = "Enabled"

    expiration {
      days = 90
    }
  }
}

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "${var.project}-${var.env}-codepipeline-bucket-${random_string.s3_unique_key.result}"
}

resource "aws_s3_bucket_acl" "codepipeline_bucket_acl" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  acl    = "private"
}
