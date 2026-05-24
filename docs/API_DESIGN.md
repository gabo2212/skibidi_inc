# API Design

## Authentication

- API style: REST
- Authorization: API Gateway Cognito User Pool authorizer
- Client header:

```http
Authorization: Bearer <access_token>
```

## Route Table

| Method | Route | Roles | Purpose |
|---|---|---|---|
| `POST` | `/tasks/generate` | `admin`, `instructor` | Generate AI task drafts with Bedrock |
| `POST` | `/tasks` | `admin`, `instructor` | Create a task |
| `GET` | `/tasks` | all | List tasks visible to the caller |
| `GET` | `/tasks/{id}` | all | Get one visible task |
| `PATCH` | `/tasks/{id}/status` | all on visible tasks | Update task status |
| `POST` | `/tasks/{id}/comments` | all on visible tasks | Add a comment |
| `POST` | `/tasks/{id}/attachment-url` | all on visible tasks | Request an S3 presigned upload URL |
| `POST` | `/tasks/{id}/assign` | `admin`, `instructor` | Assign a task and publish SNS |

## Request and Response Notes

### `POST /tasks/generate`

Example request body:

```json
{
  "objective": "Prepare a first-week AWS onboarding plan",
  "domain": "Cloud",
  "internName": "Intern Demo",
  "level": "Junior",
  "skills": ["Terraform", "AWS", "Documentation"],
  "duration": "1 week",
  "deliverable": "Checklist and summary"
}
```

Example success body:

```json
{
  "tasks": [
    {
      "title": "Draft title",
      "description": "Draft description",
      "priority": "medium",
      "category": "Cloud",
      "deliverable": "Checklist and summary",
      "validationCriteria": "Instructor review",
      "deadline": "2026-06-01"
    }
  ],
  "rawText": "..."
}
```

### `POST /tasks`

Example request body:

```json
{
  "title": "Prepare onboarding checklist",
  "description": "Create a checklist for the intern's first AWS week",
  "priority": "high",
  "category": "Operations",
  "deadline": "2026-06-01",
  "deliverable": "Shared checklist",
  "validationCriteria": "Instructor approval",
  "assignedTo": "intern.demo@example.com",
  "assignedToName": "Intern Demo",
  "source": "manual"
}
```

### `POST /tasks/{id}/assign`

Example request body:

```json
{
  "assignedTo": "intern.demo@example.com",
  "assignedToName": "Intern Demo"
}
```

### `POST /tasks/{id}/attachment-url`

Example request body:

```json
{
  "fileName": "proof.pdf",
  "contentType": "application/pdf",
  "sizeBytes": 24576
}
```

Example success body:

```json
{
  "attachment": {
    "attachmentId": "attachment_123",
    "fileName": "proof.pdf",
    "contentType": "application/pdf",
    "s3Key": "tasks/task_123/2026-05-24T12:00:00Z-proof.pdf"
  },
  "uploadUrl": "https://..."
}
```

## Error Format

The implemented backend returns flat JSON errors:

```json
{
  "code": "forbidden",
  "message": "Only instructors and admins can assign tasks."
}
```

Common status codes:

- `200` or `201` for success
- `400` for validation errors
- `403` for role or ownership violations
- `404` for missing tasks
- `502` for Bedrock generation failures
