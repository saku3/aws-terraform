output "lb_logs_bucket" {
  value = aws_s3_bucket.aws_logs_bucket
}
output "codepipeline_bucket" {
  value = aws_s3_bucket.codepipeline_bucket
}