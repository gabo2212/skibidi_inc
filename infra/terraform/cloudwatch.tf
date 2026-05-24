resource "aws_cloudwatch_log_group" "tasks_lambda" {
  name              = "/aws/lambda/${local.name_prefix}-tasks"
  retention_in_days = var.log_retention_days
}

resource "aws_cloudwatch_log_group" "generate_lambda" {
  name              = "/aws/lambda/${local.name_prefix}-generate"
  retention_in_days = var.log_retention_days
}

resource "aws_cloudwatch_log_group" "notification_worker" {
  name              = "/aws/lambda/${local.name_prefix}-notification-worker"
  retention_in_days = var.log_retention_days
}

resource "aws_cloudwatch_log_group" "api_access" {
  name              = "/aws/apigateway/${local.name_prefix}-access"
  retention_in_days = var.log_retention_days
}
