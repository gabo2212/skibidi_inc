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

output "api_base_url" {
  description = "Base URL of the deployed API stage."
  value       = "https://${aws_api_gateway_rest_api.main.id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_stage.main.stage_name}"
}

output "s3_bucket_name" {
  description = "S3 bucket for proof uploads."
  value       = aws_s3_bucket.attachments.id
}
