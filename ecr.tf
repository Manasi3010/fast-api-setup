resource "aws_ecr_repository" "fastapi_repo" {
  name = "${var.app_name}-repo"
}