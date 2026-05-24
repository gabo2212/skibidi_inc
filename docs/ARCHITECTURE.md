# Architecture

## Overview

InternTask AI Cloud is a serverless AWS application with a Flutter mobile client and Terraform-managed backend infrastructure.

Core services:

- Amazon Cognito User Pool and groups
- Amazon API Gateway REST API
- AWS Lambda
- Amazon DynamoDB
- Amazon S3
- Amazon SNS
- Amazon Bedrock
- Amazon CloudWatch
- IAM

## Architecture Diagram

```mermaid
flowchart LR
    subgraph Client
        FL[Flutter Mobile App]
    end

    subgraph AWS_Auth[AWS Auth]
        COG[Cognito User Pool<br/>groups: admin, instructor, intern]
    end

    subgraph AWS_API[AWS API Layer]
        APIGW[API Gateway REST<br/>Cognito Authorizer]
    end

    subgraph AWS_Compute[AWS Compute]
        TH[tasks_handler Lambda]
        GH[generate_handler Lambda]
        NW[notification_worker Lambda]
    end

    subgraph AWS_Data[AWS Data]
        DDB_USERS[(DynamoDB<br/>users)]
        DDB_TASKS[(DynamoDB<br/>tasks)]
        DDB_NOTIF[(DynamoDB<br/>notifications)]
        S3[(S3 attachments bucket)]
    end

    subgraph AWS_Messaging[AWS Messaging]
        SNS[(SNS<br/>assignments topic)]
    end

    subgraph AWS_AI[AWS AI]
        BR[Bedrock<br/>foundation model]
    end

    subgraph AWS_Observability[AWS Observability]
        CW[CloudWatch Logs]
    end

    FL -- USER_SRP_AUTH --> COG
    COG -- access token --> FL
    FL -- Bearer token --> APIGW
    APIGW -- /tasks, /tasks/{id}, /users, /auth, /notifications --> TH
    APIGW -- /tasks/generate --> GH
    TH --> DDB_USERS
    TH --> DDB_TASKS
    TH --> DDB_NOTIF
    TH -- presigned PUT --> S3
    FL -- direct PUT --> S3
    TH -- publish assignment event --> SNS
    SNS -- fan-out --> NW
    NW --> DDB_NOTIF
    GH --> BR
    TH --> CW
    GH --> CW
    NW --> CW
```

## Runtime Flow

1. The Flutter app signs the user in with Cognito.
2. The app fetches the Cognito access token.
3. The app sends `Authorization: Bearer <access_token>` to API Gateway.
4. API Gateway validates the token with a Cognito User Pool authorizer.
5. Lambda reads Cognito claims from `requestContext.authorizer.claims`.
6. Lambda enforces role rules for `admin`, `instructor`, and `intern`.
7. Task data is stored in DynamoDB.
8. Proof uploads use a presigned S3 `PUT` URL created by Lambda.
9. Assignment events are published to SNS.
10. An SNS-subscribed notification worker Lambda writes internal notifications to DynamoDB.
11. The Flutter app polls `GET /notifications` and marks items read through `PUT /notifications/{id}/read`.
12. Bedrock is called only for AI draft generation, and instructors must still validate before creating tasks.

## Lambda Components

- `tasks_handler`
  - `POST /tasks`
  - `GET /tasks`
  - `GET /tasks/{id}`
  - `PUT /tasks/{id}`
  - `DELETE /tasks/{id}`
  - `PATCH /tasks/{id}/status`
  - `POST /tasks/{id}/comments`
  - `POST /tasks/{id}/attachment-url`
  - `GET /tasks/{id}/attachments`
  - `POST /tasks/{id}/assign`
  - `POST /auth/profile`
  - `GET /users/me`
  - `GET /users/interns`
  - `GET /notifications`
  - `PUT /notifications/{notificationId}/read`
- `generate_handler`
  - `POST /tasks/generate`
- `notification_worker`
  - consumes SNS assignment events and writes notification items

## Cognito and Roles

- `admin`
  - full administrative visibility
  - can create, generate, assign, update, delete, and track tasks
- `instructor`
  - can create, generate, assign, update, delete, and track tasks they manage
- `intern`
  - can view assigned tasks
  - can update task status
  - can comment
  - can request proof upload URLs
  - can list their notifications and mark them read

## Storage Design

- `users` table
  - Cognito-linked app metadata
- `tasks` table
  - primary task documents, inline comments, inline attachment metadata
- `notifications` table
  - intern-facing notification records, keyed by `(userId, notificationId)`
- S3 bucket
  - private proof and attachment objects with server-side encryption

## Mobile Architecture

- Amplify Auth Cognito handles sign-in and token retrieval.
- `ApiService` sends REST requests to API Gateway.
- `AppController` manages session state, task loading, AI generation, assignment, uploads, and notifications.
- `AppConfig.load()` reads `assets/config/amplify_outputs.json` and toggles preview mode when placeholders are detected.
