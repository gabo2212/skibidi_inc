# Data Model

## DynamoDB Tables

### `interntask-ai-cloud-<stage>-users`

Purpose:

- maps Cognito identities to app metadata
- supports instructor to intern relationships

Primary key:

- partition key: `userId`

Attributes:

- `userId`
- `cognitoSub`
- `email`
- `fullName`
- `role`
- `instructorId`
- `createdAt`
- `updatedAt`

Indexes:

- `cognitoSub-index`
- `instructorId-index`

### `interntask-ai-cloud-<stage>-tasks`

Purpose:

- stores task documents used by the main API

Primary key:

- partition key: `taskId`

Attributes:

- `taskId`
- `title`
- `description`
- `assignedTo`
- `assignedToName`
- `createdBy`
- `createdByName`
- `status`
- `priority`
- `category`
- `deadline`
- `source`
- `deliverable`
- `validationCriteria`
- `blockedReason`
- `comments`
- `attachments`
- `createdAt`
- `updatedAt`

Indexes:

- `assignedTo-index`
- `createdBy-index`

Inline `comments` item shape:

- `commentId`
- `authorId`
- `authorName`
- `message`
- `createdAt`

Inline `attachments` item shape:

- `attachmentId`
- `fileName`
- `contentType`
- `sizeBytes`
- `s3Key`
- `uploadedBy`
- `createdAt`

### `interntask-ai-cloud-<stage>-notifications`

Purpose:

- stores internal notification records created by the SNS worker

Primary key:

- partition key: `notificationId`

Attributes:

- `notificationId`
- `userId`
- `taskId`
- `title`
- `message`
- `read`
- `createdAt`

## Access Patterns

- List tasks for an intern by `assignedTo-index`
- List tasks for an instructor by `createdBy-index`
- Fetch one task by `taskId`
- Find a user by `cognitoSub`
- List interns for an instructor by `instructorId`
- Write notification records when assignments happen

## S3 Object Keys

Proof files use:

```text
tasks/{taskId}/{timestamp}-{safeFileName}
```

The S3 bucket is private, and uploads happen only through Lambda-generated presigned URLs.
