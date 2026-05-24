variable "region" {
  description = "AWS region for deployment."
  type        = string
  default     = "us-east-1"
}

variable "stage" {
  description = "Deployment stage."
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name prefix."
  type        = string
  default     = "interntask-ai-cloud"
}

variable "bedrock_model_id" {
  description = "Amazon Bedrock model identifier used for task generation."
  type        = string
  default     = "anthropic.claude-3-haiku-20240307-v1:0"
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days."
  type        = number
  default     = 14
}
