# AWS, Terraform, and Database Guide

This document explains what the Terraform stack creates, what each AWS service does in InternTask AI Cloud, and how the database is structured.

## Short Version

Terraform is the deployment tool. It reads the files in `infra/terraform/` and creates the AWS resources for the project.

The AWS backend is serverless:

- Cognito handles login and roles.
- API Gateway exposes protected REST endpoints.
- Lambda runs the backend Python code.
- DynamoDB stores users, tasks, and notifications.
- S3 stores uploaded proof files.
- SNS carries task assignment notification events.
- Bedrock generates AI task drafts.
- CloudWatch stores logs.
- IAM controls what each Lambda and deploy user is allowed to do.

The Flutter app talks to API Gateway with:

```http
Authorization: Bearer <access_token>
```

## What Terraform Does

Terraform turns the project configuration into real AWS infrastructure.

Main files:

| File | Purpose |
|---|---|
| `provider.tf` | Configures Terraform providers and AWS region |
| `variables.tf` | Defines configurable values like `region`, `stage`, `project_name`, and Bedrock model |
| `main.tf` | Defines shared naming, tags, and account data |
| `cognito.tf` | Creates the Cognito User Pool, mobile app client, and role groups |
| `api_gateway.tf` | Creates the REST API, Cognito authorizer, routes, Lambda integrations, deployment, and stage |
| `lambda.tf` | Packages and deploys the Python Lambda handlers |
| `dynamodb.tf` | Creates the DynamoDB tables and indexes |
| `s3.tf` | Creates the private proof upload bucket and security settings |
| `sns.tf` | Creates the task assignment SNS topic and Lambda subscription |
| `iam.tf` | Creates Lambda execution roles and least-practical policies |
| `bedrock.tf` | Documents the Bedrock model ARN pattern used by IAM/output references |
| `cloudwatch.tf` | Creates explicit CloudWatch log groups |
| `outputs.tf` | Exposes values needed by scripts and Flutter |

Typical deployment:

```bash
cd infra/terraform
terraform init
terraform validate
terraform plan
terraform apply
```

After apply:

```bash
cd /home/gablegoob/Desktop/Skool/skibidi_inc
./scripts/export_terraform_outputs.sh
./scripts/create_demo_users.sh
```

## AWS Services Used

### Amazon Cognito

Cognito is the authentication system.

Terraform creates:

- one User Pool
- one mobile app client
- three Cognito groups:
  - `admin`
  - `instructor`
  - `intern`

The mobile app signs in through Cognito. Cognito returns an access token. The app sends that access token to API Gateway.

Backend role checks use Cognito claims from API Gateway:

- user ID
- email
- Cognito groups

### API Gateway

API Gateway is the public HTTPS entry point for the backend.

Terraform creates a REST API with a Cognito authorizer. That means requests must include a valid Cognito access token.

Main route groups:

- `/tasks`
- `/tasks/generate`
- `/tasks/{id}`
- `/tasks/{id}/status`
- `/tasks/{id}/comments`
- `/tasks/{id}/attachment-url`
- `/tasks/{id}/attachments`
- `/tasks/{id}/assign`
- `/auth/profile`
- `/users/me`
- `/users/interns`
- `/notifications`
- `/notifications/{notificationId}/read`

API Gateway forwards valid requests to Lambda using proxy integration.

### AWS Lambda

Lambda runs the backend code in `backend/lambdas/`.

Functions:

| Lambda | Handler | Purpose |
|---|---|---|
| `interntask-ai-cloud-dev-tasks` | `tasks_handler.app.lambda_handler` | Handles tasks, comments, attachments, users, and notifications routes |
| `interntask-ai-cloud-dev-generate` | `generate_handler.app.lambda_handler` | Calls Bedrock and returns AI-generated task drafts |
| `interntask-ai-cloud-dev-notification-worker` | `notification_worker.app.lambda_handler` | Consumes SNS assignment events and writes notification records |

Lambda environment variables connect code to infrastructure:

- `USERS_TABLE_NAME`
- `TASKS_TABLE_NAME`
- `NOTIFICATIONS_TABLE_NAME`
- `ATTACHMENTS_BUCKET_NAME`
- `ASSIGNMENTS_TOPIC_ARN`
- `BEDROCK_MODEL_ID`

### DynamoDB

DynamoDB is the project database.

It is NoSQL, serverless, and pay-per-request. There is no SQL server to start, patch, or size manually.

Terraform creates three tables:

- `interntask-ai-cloud-dev-users`
- `interntask-ai-cloud-dev-tasks`
- `interntask-ai-cloud-dev-notifications`

Detailed table design is below.

### Amazon S3

S3 stores proof and attachment files uploaded by interns.

The bucket is private. The mobile app does not receive AWS credentials.

Upload flow:

1. Mobile calls `POST /tasks/{id}/attachment-url`.
2. Lambda checks that the user can access the task.
3. Lambda creates an S3 object key.
4. Lambda returns a short-lived presigned `PUT` URL.
5. Mobile uploads the file directly to S3.
6. Metadata is stored on the task item in DynamoDB.

Terraform also enables:

- public access blocking
- server-side encryption
- versioning
- CORS for browser/mobile upload requests

### Amazon SNS

SNS is used for assignment notification events.

When an instructor assigns a task:

1. `tasks_handler` publishes an assignment event to SNS.
2. SNS invokes `notification_worker`.
3. `notification_worker` writes a notification item to DynamoDB.
4. The mobile app reads notifications from `GET /notifications`.

This gives the project a real notification pipeline without adding mobile push complexity.

### Amazon Bedrock

Bedrock is used for AI task generation.

Flow:

1. Instructor fills in the AI generation form.
2. Mobile calls `POST /tasks/generate`.
3. `generate_handler` builds a structured prompt.
4. Lambda calls Bedrock using the configured model ID.
5. Bedrock returns draft tasks.
6. Instructor reviews the draft before saving it as a real task.

Default model:

```text
anthropic.claude-3-haiku-20240307-v1:0
```

Bedrock model access must be enabled in the AWS account before this route works.

### IAM

IAM is AWS permissions.

There are two permission layers:

- deploy-time permissions for the IAM user running Terraform
- runtime permissions for Lambda execution roles

Terraform creates separate Lambda roles:

- tasks Lambda role
- generate Lambda role
- notification worker role

Those roles are scoped to the resources they need. For example, the generate Lambda gets Bedrock invoke permission, while the notification worker gets DynamoDB write permission for notifications.

The IAM user running Terraform still needs permission to create infrastructure. If `terraform apply` fails with `AccessDenied`, the AWS user does not have enough deploy permissions.

### CloudWatch Logs

CloudWatch stores logs for:

- task Lambda
- generate Lambda
- notification worker Lambda
- API Gateway access logs

These logs are the first place to check when a deployed route fails.

## Database Design

### `users` Table

Table name:

```text
interntask-ai-cloud-dev-users
```

Primary key:

| Key | Type | Meaning |
|---|---|---|
| `userId` | string | app-level user ID |

Attributes:

| Attribute | Meaning |
|---|---|
| `cognitoSub` | Cognito user identifier |
| `email` | user email |
| `fullName` | display name |
| `role` | `admin`, `instructor`, or `intern` |
| `instructorId` | instructor linked to an intern |
| `createdAt` | creation timestamp |
| `updatedAt` | last update timestamp |

Indexes:

| Index | Purpose |
|---|---|
| `cognitoSub-index` | find a profile by Cognito identity |
| `instructorId-index` | list interns linked to one instructor |

### `tasks` Table

Table name:

```text
interntask-ai-cloud-dev-tasks
```

Primary key:

| Key | Type | Meaning |
|---|---|---|
| `taskId` | string | unique task ID |

Attributes:

| Attribute | Meaning |
|---|---|
| `title` | task title |
| `description` | task details |
| `assignedTo` | intern user ID or email |
| `assignedToName` | display name for the intern |
| `createdBy` | instructor/admin who created it |
| `createdByName` | creator display name |
| `status` | `todo`, `in_progress`, `blocked`, `submitted`, `changes_requested`, `validated`, etc. |
| `priority` | `low`, `medium`, `high`, or `urgent` |
| `category` | task category |
| `deadline` | due date |
| `source` | `manual` or `bedrock` |
| `deliverable` | expected output |
| `validationCriteria` | approval criteria |
| `blockedReason` | optional blocker note |
| `comments` | inline list of comments |
| `attachments` | inline list of proof file metadata |
| `createdAt` | creation timestamp |
| `updatedAt` | last update timestamp |

Indexes:

| Index | Purpose |
|---|---|
| `assignedTo-index` | list tasks for one intern |
| `createdBy-index` | list tasks created by one instructor |

Inline comment shape:

```json
{
  "commentId": "comment_...",
  "authorId": "user-id",
  "authorName": "User Name",
  "message": "Comment text",
  "createdAt": "2026-05-24T12:00:00Z"
}
```

Inline attachment shape:

```json
{
  "attachmentId": "attachment_...",
  "fileName": "proof.pdf",
  "contentType": "application/pdf",
  "sizeBytes": 12345,
  "s3Key": "tasks/task_123/2026-05-24T12:00:00Z-proof.pdf",
  "uploadedBy": "user-id",
  "createdAt": "2026-05-24T12:00:00Z"
}
```

### `notifications` Table

Table name:

```text
interntask-ai-cloud-dev-notifications
```

Primary key:

| Key | Type | Meaning |
|---|---|---|
| `userId` | string | recipient user |
| `notificationId` | string | unique notification ID |

Attributes:

| Attribute | Meaning |
|---|---|
| `taskId` | related task |
| `title` | notification title |
| `message` | notification text |
| `read` | boolean read state |
| `createdAt` | creation timestamp |

## How Data Moves Through the App

### Instructor creates a task

1. Instructor signs in with Cognito.
2. Flutter sends `POST /tasks` with the access token.
3. API Gateway validates the token.
4. Lambda reads claims and checks role.
5. Lambda writes the task to DynamoDB.
6. If assigned, Lambda publishes an SNS event.
7. SNS triggers the notification worker.
8. Notification worker writes to the notifications table.

### Intern updates a task

1. Intern signs in.
2. Flutter calls `GET /tasks`.
3. Lambda queries tasks by `assignedTo`.
4. Intern opens a task and calls `PATCH /tasks/{id}/status`.
5. Lambda verifies the intern owns that task.
6. Lambda updates the DynamoDB item.

### Intern uploads proof

1. Intern requests an upload URL.
2. Lambda validates access.
3. Lambda creates attachment metadata and a presigned S3 URL.
4. Flutter uploads directly to S3.
5. Instructor can see proof metadata on the task.

## Terraform Outputs

Terraform outputs are values that other parts of the project need after deployment.

Important outputs:

| Output | Used by |
|---|---|
| `aws_region` | Flutter config and scripts |
| `cognito_user_pool_id` | Flutter Cognito setup |
| `cognito_user_pool_client_id` | Flutter Cognito setup |
| `api_gateway_url` / `api_base_url` | Flutter API client |
| `attachments_bucket_name` / `s3_bucket_name` | docs/scripts/debugging |
| `tasks_table_name` | docs/scripts/debugging |
| `users_table_name` | docs/scripts/debugging |
| `notifications_table_name` | docs/scripts/debugging |
| `sns_topic_arn` | docs/scripts/debugging |

Export outputs into the app:

```bash
./scripts/export_terraform_outputs.sh
```

That writes:

```text
mobile/assets/config/amplify_outputs.json
```

## Current Deployment Blocker

The app can run in preview mode without AWS.

For real AWS deployment, the IAM user running Terraform must be allowed to create and manage the required resources. If Terraform fails with `AccessDenied`, the account credentials are valid but the user does not have enough permissions.

Common permissions needed:

- `apigateway:*`
- `cognito-idp:*`
- `dynamodb:*`
- `lambda:*`
- `iam:CreateRole`
- `iam:PassRole`
- `iam:PutRolePolicy`
- `iam:AttachRolePolicy`
- `s3:*` for the project bucket
- `sns:*`
- `logs:*`
- `bedrock:InvokeModel`

For a school demo account, the simplest fix is usually having the account owner attach a broad admin or power-user policy temporarily, deploy the stack, then remove it after the demo.

## Preview Mode

Preview mode is local-only and does not use AWS.

It is useful for:

- checking screens
- testing navigation
- taking early UI screenshots

It does not prove:

- real Cognito login
- API Gateway authorization
- DynamoDB writes
- S3 uploads
- SNS notifications
- Bedrock generation

Run preview mode:

```bash
cd mobile
flutter run
```

Temporary preview accounts:

```text
admin.demo@example.com
instructor.demo@example.com
intern.demo@example.com
```

Password:

```text
Password123!
```
