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

- partition key: `userId`
- sort key: `notificationId`

Attributes:

- `notificationId`
- `userId`
- `taskId`
- `title`
- `message`
- `read`
- `readAt` (set when the user marks the notification as read)
- `createdAt`

## Design Trade-off vs. the Brief

The original brief sketches `TaskComments` and `Attachments` as separate tables alongside `Tasks`. This implementation keeps both as **inline lists on the `tasks` row** instead:

- One `GetItem` returns the full task view (description, comments, attachments) the mobile app needs
- No second query is required to render the task detail screen
- Comments and attachments per task stay small enough (well under DynamoDB's 400 KB item limit) for a demo cohort

The downside is that comments and attachments cannot be queried independently of the task they belong to. If a future iteration needs that (e.g., a global "recent comments" feed or per-user attachment history), promoting them to dedicated tables is a strictly additive change — the existing tasks table keeps working while new tables fill in the missing access patterns.

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
