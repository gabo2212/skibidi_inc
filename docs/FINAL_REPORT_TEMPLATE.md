# Final Report Template

## Project Title

InternTask AI Cloud

## Problem Statement

Explain the internship task management problem and why a cloud-native mobile solution is useful.

## Objectives

- Secure user authentication and role separation
- Instructor task creation and assignment
- Intern progress tracking
- Proof upload support
- Notification support
- AI-assisted task drafting with Amazon Bedrock

## AWS Services Used

- Amazon Cognito
- Amazon API Gateway
- AWS Lambda
- Amazon DynamoDB
- Amazon S3
- Amazon SNS
- Amazon Bedrock
- IAM
- Amazon CloudWatch
- Terraform

## Architecture

Describe the end-to-end flow:

- Flutter mobile app
- Cognito authentication
- API Gateway Cognito authorizer
- Lambda business logic
- DynamoDB persistence
- S3 presigned upload flow
- SNS notification publishing
- Bedrock AI generation

## Authentication and Roles

Explain:

- Cognito User Pool login
- access token retrieval
- `Authorization: Bearer <access_token>`
- Cognito groups:
  - `admin`
  - `instructor`
  - `intern`

## API Gateway and Lambda Flow

Document the implemented routes and how claims are parsed from API Gateway request context.

## DynamoDB Schema

Explain:

- `users` table
- `tasks` table
- `notifications` table
- inline `comments`
- inline `attachments`

## S3 Upload Flow

Explain:

1. mobile requests `/tasks/{id}/attachment-url`
2. Lambda validates access
3. Lambda generates a presigned `PUT` URL
4. mobile uploads directly to S3
5. attachment metadata remains linked to the task

## SNS Notification Flow

Explain:

1. assignment triggers SNS publish
2. notification worker Lambda consumes the event
3. a notification record is written to DynamoDB

## Bedrock Generation Flow

Explain:

1. instructor submits generation context
2. Lambda builds a structured prompt
3. Bedrock returns draft tasks
4. instructor validates before real task creation

## IAM and Security Choices

Explain:

- least-privilege Lambda IAM roles
- protected API methods
- private S3 bucket
- server-side encryption
- CloudWatch logging
- no hardcoded secrets

## Terraform Deployment

Document:

- variables
- outputs
- deployment commands
- mobile config export

## Testing and Validation

List commands and real outcomes for:

- `terraform fmt`
- `terraform init`
- `terraform validate`
- `terraform plan`
- backend `pytest`
- `flutter analyze`
- `flutter test`

## Demo Evidence

List the screenshots and the teacher demo flow from `docs/DEMO_CHECKLIST.md`.
