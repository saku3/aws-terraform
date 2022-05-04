resource "aws_codestarconnections_connection" "connection" {
  name          = "${var.project}-${var.env}-connection"
  provider_type = "GitHub"
}