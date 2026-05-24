# Amazon Bedrock configuration
#
# Bedrock foundation models are managed by AWS — there is no dedicated
# Terraform resource for the model itself. The `generate_handler` Lambda
# calls Bedrock through the `bedrock-runtime` client and the IAM
# permissions live in `iam.tf` under `data.aws_iam_policy_document.generate_policy`.
#
# This file centralises Bedrock-related locals so the rest of the stack
# (logs, future provisioned-throughput resources, etc.) can reference a
# single source of truth.

locals {
  bedrock_model_id = var.bedrock_model_id

  bedrock_runtime_arn_pattern = "arn:${data.aws_partition.current.partition}:bedrock:${var.region}::foundation-model/${var.bedrock_model_id}"
}

output "bedrock_model_id" {
  description = "Foundation model id used by the generate handler."
  value       = local.bedrock_model_id
}

output "bedrock_runtime_arn_pattern" {
  description = "ARN pattern the generate Lambda is permitted to invoke."
  value       = local.bedrock_runtime_arn_pattern
}
