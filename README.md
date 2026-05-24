# InternTask AI Cloud

InternTask AI Cloud is a demo-ready AWS final project for internship task management. It includes a Flutter mobile client, a Python Lambda backend, and Terraform infrastructure for Cognito, API Gateway, DynamoDB, S3, SNS, Bedrock, IAM, and CloudWatch.

## Repository Layout

- `mobile/`: Flutter application with Cognito sign-in, role-aware screens, and API/S3 integration
- `backend/lambdas/`: Python Lambda handlers, shared utilities, and unit tests
- `infra/terraform/`: Terraform for Cognito, API Gateway, DynamoDB, S3, SNS, Lambda, IAM, and logs
- `docs/`: architecture, setup, data model, API design, demo checklist, and report template
- `scripts/`: config export, demo user creation, smoke tests, packaging, and teardown helpers
- `screenshots/`: screenshots to capture before submission

## What Is Implemented

- Cognito User Pool authentication with `admin`, `instructor`, and `intern` groups
- API Gateway REST API protected by a Cognito authorizer
- Python Lambda routes for task generation, creation, assignment, status updates, comments, and attachment URLs
- DynamoDB storage for users, tasks, and notifications
- S3 presigned upload flow for proof files
- SNS notifications for assignment events
- Bedrock-backed task draft generation
- Flutter screens for login, instructor workflows, intern workflows, task detail, comments, and proof upload
- Shell scripts for deployment-adjacent tasks

## Validation Commands

### Terraform

```bash
cd infra/terraform
terraform fmt
terraform init
terraform validate
terraform plan
```

### Backend

```bash
cd backend/lambdas
python3 -m venv .venv
. .venv/bin/activate
pip install -r requirements-dev.txt
pytest
```

### Flutter

```bash
cd mobile
flutter pub get
flutter analyze
flutter test
```

## Deployment Flow

1. Read [docs/INSTALLATION.md](/home/gablegoob/Desktop/Skool/skibidi_inc/docs/INSTALLATION.md).
2. Deploy Terraform from `infra/terraform/`.
3. Export Terraform outputs into `mobile/assets/config/amplify_outputs.json`.
4. Create demo Cognito users and assign them to the right groups.
5. Run the Flutter app and follow [docs/DEMO_CHECKLIST.md](/home/gablegoob/Desktop/Skool/skibidi_inc/docs/DEMO_CHECKLIST.md).

## Project Brief Source

The teacher brief remains the functional source of truth:

- `/home/gablegoob/Downloads/examens_96-POC-exemple-de-projet-final-AWS.md at main · devopsgodhrehouma_examens (5_24_2026 10：18：59 AM).html`
