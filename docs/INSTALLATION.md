# Installation

All commands assume you have cloned this repository and `cd`d into it. Replace any environment-specific paths with your own. There are no project-specific absolute paths in this guide.

## Prerequisites

- AWS account with access to Cognito, API Gateway, Lambda, DynamoDB, S3, SNS, IAM, CloudWatch, and Bedrock
- AWS CLI configured locally
- Terraform `>= 1.5`
- Python 3.12
- Flutter SDK 3.x

## 1. Deploy Infrastructure

```bash
cd infra/terraform
terraform fmt
terraform init
terraform validate
terraform plan
terraform apply
```

Notes:

- `terraform plan` and `terraform apply` require valid AWS credentials.
- The Terraform package currently uses the `archive` provider to zip Lambda source automatically.
- Amazon Bedrock model access must be enabled in your AWS account for the configured `bedrock_model_id` (default: `anthropic.claude-3-haiku-20240307-v1:0`).

## 2. Export Runtime Config to Flutter

After `terraform apply`, from the repository root:

```bash
./scripts/export_terraform_outputs.sh
```

This writes `mobile/assets/config/amplify_outputs.json` using these Terraform outputs:

- `aws_region`
- `cognito_user_pool_id`
- `cognito_user_pool_client_id`
- `api_gateway_url` (with `api_base_url` as backward-compatible alias)
- `attachments_bucket_name` (with `s3_bucket_name` as backward-compatible alias)
- `tasks_table_name`
- `notifications_table_name`
- `sns_topic_arn`

## 3. Create Demo Users

```bash
./scripts/create_demo_users.sh
```

Default demo accounts:

- `admin.demo@example.com`
- `instructor.demo@example.com`
- `intern.demo@example.com`

Default permanent password:

- `Password123!`

## 4. Validate the Backend

```bash
cd backend/lambdas
python3 -m venv .venv
. .venv/bin/activate
pip install -r requirements-dev.txt
pytest
python3 -m py_compile $(find . -name '*.py' | sort)
```

## 5. Validate the Mobile App

```bash
cd mobile
flutter pub get
flutter analyze
flutter test
```

## 6. Run the Mobile App

```bash
cd mobile
flutter run
```

If Terraform outputs are still placeholders, the app runs in preview mode so the UI remains demoable locally. After exporting real outputs, the same client uses Cognito and API Gateway directly.
