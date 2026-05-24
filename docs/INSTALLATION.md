# Installation

## Prerequisites

- AWS account with access to Cognito, API Gateway, Lambda, DynamoDB, S3, SNS, IAM, CloudWatch, and Bedrock
- AWS CLI configured locally
- Terraform `>= 1.15`
- Python 3
- Flutter SDK

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

## 2. Export Runtime Config to Flutter

After `terraform apply`, run:

```bash
cd /home/gablegoob/Desktop/Skool/skibidi_inc
./scripts/export_terraform_outputs.sh
```

This writes `mobile/assets/config/amplify_outputs.json` using Terraform outputs:

- `aws_region`
- `cognito_user_pool_id`
- `cognito_user_pool_client_id`
- `api_base_url`

## 3. Create Demo Users

```bash
cd /home/gablegoob/Desktop/Skool/skibidi_inc
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
