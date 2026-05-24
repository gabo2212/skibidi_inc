# Demo Checklist

## Exact Teacher Demo Flow

1. Deploy Terraform with `terraform apply` from `infra/terraform/`.
2. Export Terraform outputs into the Flutter app with `./scripts/export_terraform_outputs.sh`.
3. Create demo Cognito users with `./scripts/create_demo_users.sh`.
4. Sign in as the instructor in the Flutter app.
5. Open the Bedrock task generation screen and generate a draft task.
6. Approve or copy the draft into the create-task flow and assign it to the intern.
7. Sign in as the intern and show the assigned task list.
8. Open the task and update the task status.
9. Add a comment from the intern view.
10. Upload a proof file and show the success state.
11. Open the notifications bell on either dashboard to show the SNS-driven inbox; mark a notification read.
12. Return to the instructor view and show progress plus AWS resources/screenshots.

## Pre-Demo Sanity Run

Run these before recording or presenting so you do not get surprised live:

```bash
cd infra/terraform && terraform fmt && terraform init && terraform validate && terraform plan
cd backend/lambdas && pytest
cd mobile && flutter pub get && flutter analyze && flutter test
```

If any of the tools above are missing on the demo machine, fall back to preview mode (the Flutter app runs without real AWS configuration) and explicitly call this out at the start of the demo.

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

The `screenshots/` folder contains placeholder filenames only. Replace each placeholder by taking the screenshot live during a real run — do **not** commit fabricated images.

Required captures:

- `01-login.png` — login screen with branding visible
- `02-instructor-dashboard.png` — instructor home with task counts
- `03-bedrock-generation.png` — Bedrock draft generation screen with at least one returned draft
- `04-task-assignment.png` — task creation or assignment flow
- `05-intern-task-list.png` — intern view of assigned tasks
- `06-task-detail-comment.png` — task detail screen with a freshly added comment
- `07-proof-upload.png` — proof upload screen, success state
- `08-notifications.png` — notifications screen with at least one item (read and unread visible)
- `09-aws-console-overview.png` — AWS Console showing the deployed resources

For the AWS Console capture, include at minimum:

- Cognito User Pool and groups
- API Gateway stage URL
- DynamoDB tables (`users`, `tasks`, `notifications`)
- S3 bucket
- SNS topic
- Lambda functions (`tasks`, `generate`, `notification_worker`)
- Bedrock model access (Bedrock console "Model access" page)
