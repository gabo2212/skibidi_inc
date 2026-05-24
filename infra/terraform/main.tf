data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

locals {
  name_prefix = "${var.project_name}-${var.stage}"

  common_tags = {
    Project     = var.project_name
    Stage       = var.stage
    ManagedBy   = "terraform"
    Application = "InternTaskAICloud"
  }

  bucket_name = lower("${var.project_name}-${var.stage}-${data.aws_caller_identity.current.account_id}-proofs")
}
