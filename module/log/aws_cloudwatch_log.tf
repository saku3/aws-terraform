resource "aws_cloudwatch_log_group" "logs" {
  name              = "/ecs/${var.env}/${var.project}-${var.app_name}"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "codebuild" {
  name              = "/codebuild/${var.app_name}/log"
  retention_in_days = 30
}