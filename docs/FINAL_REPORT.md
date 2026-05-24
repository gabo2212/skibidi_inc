# Final Report

## Project Title

InternTask AI Cloud — a role-aware mobile task manager for internship cohorts, backed by serverless AWS services.

## Problem Statement

Internship programs need a simple way for instructors to assign tasks, track progress, and validate deliverables, while interns need a focused mobile experience for working on those tasks and uploading proof. A cloud-native, mobile-first solution removes the friction of email or chat-driven follow-up and gives both sides a single source of truth.

InternTask AI Cloud addresses this by combining:

- A Flutter mobile client with role-aware screens for admins, instructors, and interns
- A serverless AWS backend that scales with cohort size and is cheap to run when idle
- AI-assisted task drafting via Amazon Bedrock so instructors can produce realistic task specs in seconds

## Objectives

- Secure user authentication and role separation
- Instructor task creation, assignment, update, and deletion
- Intern progress tracking and proof submission
- Internal notifications when tasks are assigned
- AI-assisted task drafting with Amazon Bedrock
- Reproducible infrastructure managed by Terraform

## AWS Services Used

| Service | Purpose |
|---|---|
| Amazon Cognito | User pool and group-based authorization (admin / instructor / intern) |
| Amazon API Gateway | REST API protected by a Cognito authorizer |
| AWS Lambda | Task, generation, and notification worker handlers |
| Amazon DynamoDB | Storage for users, tasks (with inline comments and attachments), and notifications |
| Amazon S3 | Private attachment bucket with presigned PUT uploads |
| Amazon SNS | Fan-out for assignment events to the notification worker |
| Amazon Bedrock | Foundation-model-backed task draft generation |
| AWS IAM | Least-privilege roles per Lambda |
| Amazon CloudWatch | Lambda and API Gateway access logs |
| Terraform | Declarative infrastructure for all of the above |

## Architecture

See [ARCHITECTURE.md](ARCHITECTURE.md) for the Mermaid diagram and component details. The end-to-end flow is:

1. The Flutter app signs the user in with Cognito (`USER_SRP_AUTH`).
2. The app sends each authenticated request with `Authorization: Bearer <access_token>`.
3. API Gateway validates the token with the Cognito authorizer and forwards the request as a Lambda proxy event.
4. `tasks_handler` parses Cognito claims, enforces the role, and reads/writes DynamoDB.
5. Assignment events publish to SNS; the notification worker writes a notification row to DynamoDB.
6. Proof uploads are uploaded directly from the mobile app to S3 using a Lambda-issued presigned `PUT` URL.
7. `generate_handler` calls Bedrock for AI task drafts; instructors confirm the draft before creating the real task.

## Authentication and Roles

- Cognito User Pool with `email` as the username attribute
- Three Cognito groups: `admin`, `instructor`, `intern`
- Lambda derives the principal role from `cognito:groups` in the access token claims
- API Gateway uses a `COGNITO_USER_POOLS` authorizer on every protected method
- The Flutter `AuthService` uses Amplify to obtain and refresh tokens; when no real configuration is present, the app falls back to a local preview principal so the UI remains demoable

## API Gateway and Lambda Flow

Every request first hits API Gateway. The Cognito authorizer puts the verified claims into `event.requestContext.authorizer.claims`. The Lambda `common.auth.parse_principal` helper reads these claims and produces a typed `Principal`. The handler then dispatches by `(httpMethod, resource)` and applies the appropriate role guard before touching DynamoDB.

See [API_DESIGN.md](API_DESIGN.md) for the full route table.

## DynamoDB Schema

See [DATA_MODEL.md](DATA_MODEL.md).

Key design choices:

- The `tasks` table embeds comments and attachment metadata as inline lists. This trades the relational normalization of separate `TaskComments` and `Attachments` tables for fewer reads per task view, simpler API responses, and lower operational cost on the demo scale.
- The `notifications` table uses `userId` as the hash key and `notificationId` as the range key so the intern's inbox is a single `Query` away.
- Global secondary indexes provide fast assignee and creator lookups on `tasks`, plus Cognito-sub and instructor-id lookups on `users`.

## S3 Upload Flow

1. Mobile requests `POST /tasks/{id}/attachment-url`
2. Lambda validates access and builds attachment metadata
3. Lambda generates a presigned `PUT` URL valid for 15 minutes
4. Mobile uploads directly to S3
5. Attachment metadata is persisted inline on the task and visible via `GET /tasks/{id}/attachments`

The S3 bucket is private, encrypted with AES-256, has versioning enabled, and a strict public-access block.

## SNS Notification Flow

1. `POST /tasks` or `POST /tasks/{id}/assign` triggers an SNS publish
2. The notification worker Lambda is subscribed to the topic
3. The worker writes a row into the `notifications` table
4. The mobile app polls `GET /notifications` and marks items read with `PUT /notifications/{notificationId}/read`

## Bedrock Generation Flow

1. Instructor opens "Generate with AI" and supplies an objective, domain, level, skills, duration, and deliverable
2. Lambda builds a system + user prompt with strict JSON instructions
3. Bedrock returns text; Lambda parses and normalizes the structured output
4. Instructor reviews the drafts and chooses which ones to turn into real tasks

## IAM and Security Choices

- Each Lambda has its own role with the minimum DynamoDB / S3 / SNS / Bedrock actions it needs
- API Gateway methods all require Cognito auth — no public routes
- The attachment bucket is private with public access blocked and SSE enabled
- CloudWatch log groups are created for every Lambda and the API access log
- No secrets or account-specific identifiers are checked into the repo
- The mobile app reads configuration from `assets/config/amplify_outputs.json`, generated from Terraform outputs

## Terraform Deployment

Variables of interest:

- `region` — AWS region (default `us-east-1`)
- `stage` — deployment stage (default `dev`)
- `project_name` — name prefix (default `interntask-ai-cloud`)
- `bedrock_model_id` — foundation model id (default Claude 3 Haiku)

Outputs (brief-aligned names, with legacy aliases kept for compatibility):

- `cognito_user_pool_id`
- `cognito_user_pool_client_id`
- `api_gateway_url` (alias: `api_base_url`)
- `tasks_table_name`
- `users_table_name`
- `notifications_table_name`
- `attachments_bucket_name` (alias: `s3_bucket_name`)
- `sns_topic_arn`
- `bedrock_model_id`
- `aws_region`

Deploy with:

```bash
cd infra/terraform
terraform init
terraform validate
terraform plan
terraform apply
```

Then export the mobile config:

```bash
./scripts/export_terraform_outputs.sh
```

## Testing and Validation

Local results obtained while preparing this submission are recorded in `docs/DEMO_CHECKLIST.md`. The reproducible commands are:

- `cd infra/terraform && terraform fmt && terraform init && terraform validate && terraform plan`
- `cd backend/lambdas && pip install -r requirements-dev.txt && pytest`
- `cd mobile && flutter pub get && flutter analyze && flutter test`

When a tool is unavailable in the environment running the validation (no AWS credentials, no Flutter SDK, etc.) the relevant section in the demo checklist explicitly says so.

## Data Model Trade-off

The brief sketches separate `TaskComments` and `Attachments` tables. This implementation keeps both as inline lists inside the `tasks` row instead. The trade-off is documented in [DATA_MODEL.md](DATA_MODEL.md) — fewer table reads per task view at the cost of looser referential separation. For a demo cohort and the access patterns used by the mobile app, the inline approach is enough; if a future iteration needs to scale comments or attachments independently (e.g., very long discussion threads or very many proof files per task), splitting them into dedicated tables is a straightforward additive change.

## Demo Evidence

The teacher demo flow lives in [DEMO_CHECKLIST.md](DEMO_CHECKLIST.md). The `screenshots/` folder contains placeholder filenames that should be replaced with real captures taken during the live demo. Screenshots are intentionally not fabricated; they must be produced from a real deploy or local run.
