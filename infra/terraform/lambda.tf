data "archive_file" "tasks_handler" {
  type        = "zip"
  source_dir  = "${path.module}/../../backend/lambdas"
  output_path = "${path.module}/tasks_handler.zip"
}

data "archive_file" "generate_handler" {
  type        = "zip"
  source_dir  = "${path.module}/../../backend/lambdas"
  output_path = "${path.module}/generate_handler.zip"
}

data "archive_file" "notification_worker" {
  type        = "zip"
  source_dir  = "${path.module}/../../backend/lambdas"
  output_path = "${path.module}/notification_worker.zip"
}

resource "aws_lambda_function" "tasks" {
  function_name = "${local.name_prefix}-tasks"
  role          = aws_iam_role.tasks_lambda.arn
  runtime       = "python3.12"
  handler       = "tasks_handler.app.lambda_handler"
  filename      = data.archive_file.tasks_handler.output_path

  source_code_hash = data.archive_file.tasks_handler.output_base64sha256
  timeout          = 30
  memory_size      = 256

  environment {
    variables = {
      PROJECT_NAME             = var.project_name
      STAGE                    = var.stage
      USERS_TABLE_NAME         = aws_dynamodb_table.users.name
      TASKS_TABLE_NAME         = aws_dynamodb_table.tasks.name
      ATTACHMENTS_BUCKET_NAME  = aws_s3_bucket.attachments.id
      ASSIGNMENTS_TOPIC_ARN    = aws_sns_topic.assignments.arn
      NOTIFICATIONS_TABLE_NAME = aws_dynamodb_table.notifications.name
    }
  }

  depends_on = [aws_cloudwatch_log_group.tasks_lambda]
}

resource "aws_lambda_function" "generate" {
  function_name = "${local.name_prefix}-generate"
  role          = aws_iam_role.generate_lambda.arn
  runtime       = "python3.12"
  handler       = "generate_handler.app.lambda_handler"
  filename      = data.archive_file.generate_handler.output_path

  source_code_hash = data.archive_file.generate_handler.output_base64sha256
  timeout          = 30
  memory_size      = 256

  environment {
    variables = {
      PROJECT_NAME     = var.project_name
      STAGE            = var.stage
      USERS_TABLE_NAME = aws_dynamodb_table.users.name
      BEDROCK_MODEL_ID = var.bedrock_model_id
    }
  }

  depends_on = [aws_cloudwatch_log_group.generate_lambda]
}

resource "aws_lambda_function" "notification_worker" {
  function_name = "${local.name_prefix}-notification-worker"
  role          = aws_iam_role.notification_worker.arn
  runtime       = "python3.12"
  handler       = "notification_worker.app.lambda_handler"
  filename      = data.archive_file.notification_worker.output_path

  source_code_hash = data.archive_file.notification_worker.output_base64sha256
  timeout          = 15
  memory_size      = 256

  environment {
    variables = {
      NOTIFICATIONS_TABLE_NAME = aws_dynamodb_table.notifications.name
    }
  }

  depends_on = [aws_cloudwatch_log_group.notification_worker]
}

resource "aws_lambda_permission" "api_invoke_tasks" {
  statement_id  = "AllowApiGatewayInvokeTasks"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.tasks.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_invoke_generate" {
  statement_id  = "AllowApiGatewayInvokeGenerate"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.generate.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "sns_invoke_notification_worker" {
  statement_id  = "AllowSnsInvokeNotificationWorker"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notification_worker.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.assignments.arn
}
