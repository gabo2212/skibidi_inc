output "aws_region" {
  description = "AWS region used by the project."
  value       = var.region
}

output "cognito_user_pool_id" {
  description = "Cognito User Pool ID."
  value       = aws_cognito_user_pool.main.id
}

output "cognito_user_pool_client_id" {
  description = "Cognito User Pool Client ID."
  value       = aws_cognito_user_pool_client.mobile.id
}

output "api_gateway_url" {
  description = "Base URL of the deployed API stage (brief-aligned name)."
  value       = "https://${aws_api_gateway_rest_api.main.id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_stage.main.stage_name}"
}

output "api_base_url" {
  description = "Backward-compatible alias for api_gateway_url. Used by older scripts."
  value       = "https://${aws_api_gateway_rest_api.main.id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_stage.main.stage_name}"
}

output "tasks_table_name" {
  description = "DynamoDB table that stores task documents."
  value       = aws_dynamodb_table.tasks.name
}

output "users_table_name" {
  description = "DynamoDB table that stores app user metadata."
  value       = aws_dynamodb_table.users.name
}

output "notifications_table_name" {
  description = "DynamoDB table that stores in-app notifications."
  value       = aws_dynamodb_table.notifications.name
}

output "attachments_bucket_name" {
  description = "S3 bucket for proof uploads (brief-aligned name)."
  value       = aws_s3_bucket.attachments.id
}

output "s3_bucket_name" {
  description = "Backward-compatible alias for attachments_bucket_name."
  value       = aws_s3_bucket.attachments.id
}

output "sns_topic_arn" {
  description = "SNS topic ARN that receives assignment events."
  value       = aws_sns_topic.assignments.arn
}
