resource "aws_sns_topic" "assignments" {
  name = "${local.name_prefix}-assignments"
}

resource "aws_sns_topic_subscription" "notification_worker" {
  topic_arn = aws_sns_topic.assignments.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.notification_worker.arn
}
