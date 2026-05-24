# InternTask AI Cloud

InternTask AI Cloud is a demo-ready AWS final project for internship task management. It includes a Flutter mobile client, a Python Lambda backend, and Terraform infrastructure for Cognito, API Gateway, DynamoDB, S3, SNS, Bedrock, IAM, and CloudWatch.

## Repository Layout

- `mobile/`: Flutter application with Cognito sign-in, role-aware screens, and API/S3 integration
- `backend/lambdas/`: Python Lambda handlers, shared utilities, and unit tests
- `infra/terraform/`: Terraform for Cognito, API Gateway, DynamoDB, S3, SNS, Lambda, IAM, Bedrock, and logs
- `docs/`: architecture, setup, data model, API design, demo checklist, and final report
- `scripts/`: config export, demo user creation, smoke tests, packaging, and teardown helpers
- `screenshots/`: screenshots to capture before submission

## What Is Implemented

- Cognito User Pool authentication with `admin`, `instructor`, and `intern` groups
- API Gateway REST API protected by a Cognito authorizer
- Python Lambda routes for task generation, creation, assignment, status updates, comments, attachment URLs, attachments listing, task updates and deletion, user profile, intern listing, and notifications
- DynamoDB storage for users, tasks, and notifications
- S3 presigned upload flow for proof files
- SNS notifications for assignment events
- Bedrock-backed task draft generation
- Flutter screens for login, instructor workflows, intern workflows, task detail, comments, proof upload, and notifications
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

1. Read [docs/INSTALLATION.md](docs/INSTALLATION.md).
2. Deploy Terraform from `infra/terraform/`.
3. Export Terraform outputs into `mobile/assets/config/amplify_outputs.json` with `./scripts/export_terraform_outputs.sh`.
4. Create demo Cognito users and assign them to the right groups with `./scripts/create_demo_users.sh`.
5. Run the Flutter app and follow [docs/DEMO_CHECKLIST.md](docs/DEMO_CHECKLIST.md).

## Documentation Index

- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) — system overview and diagram
- [docs/API_DESIGN.md](docs/API_DESIGN.md) — REST contract
- [docs/DATA_MODEL.md](docs/DATA_MODEL.md) — DynamoDB tables and access patterns
- [docs/INSTALLATION.md](docs/INSTALLATION.md) — deployment steps
- [docs/DEMO_CHECKLIST.md](docs/DEMO_CHECKLIST.md) — teacher demo flow
- [docs/FINAL_REPORT.md](docs/FINAL_REPORT.md) — final submission report
- [docs/FINAL_REPORT_TEMPLATE.md](docs/FINAL_REPORT_TEMPLATE.md) — fill-in-the-blanks template

## Preview Mode

If Terraform outputs have not been exported yet (or the `amplify_outputs.json` asset still contains the placeholder values), the Flutter app starts in preview mode with a local in-memory data set. This keeps the UI demoable without AWS credentials and lets reviewers see the screens before infrastructure is deployed.
