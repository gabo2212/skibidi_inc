# Demo Checklist

## Exact Teacher Demo Flow

1. Deploy Terraform with `terraform apply` from `infra/terraform/`.
2. Create and sign in demo users with `./scripts/create_demo_users.sh`.
3. Sign in as the instructor in the Flutter app.
4. Open the Bedrock task generation screen and generate a draft task.
5. Approve or copy the draft into the create-task flow and assign it to the intern.
6. Sign in as the intern and show the assigned task list.
7. Open the task and update the task status.
8. Add a comment from the intern view.
9. Upload a proof file and show the success state.
10. Return to the instructor view and show progress plus AWS resources/screenshots.

## Supporting Commands

### Export mobile config

```bash
./scripts/export_terraform_outputs.sh
```

### Backend tests

```bash
cd backend/lambdas
python3 -m venv .venv
. .venv/bin/activate
pip install -r requirements-dev.txt
pytest
```

### Flutter validation

```bash
cd mobile
flutter pub get
flutter analyze
flutter test
```

## Screenshots To Capture

- Login screen
- Instructor dashboard
- Bedrock generation screen
- Task creation or assignment screen
- Intern task list
- Task detail with status or comment update
- Proof upload screen
- Terraform outputs
- AWS Console resources:
  - Cognito User Pool and groups
  - API Gateway
  - DynamoDB tables
  - S3 bucket
  - SNS topic
  - Lambda functions
