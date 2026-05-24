from common.http import ApiError
from common.utils import build_s3_key, make_id


STATUS_ALIASES = {
    "todo": "todo",
    "to do": "todo",
    "a faire": "todo",
    "à faire": "todo",
    "in progress": "in_progress",
    "in_progress": "in_progress",
    "en cours": "in_progress",
    "blocked": "blocked",
    "bloque": "blocked",
    "bloqué": "blocked",
    "submitted": "submitted",
    "soumis": "submitted",
    "changes_requested": "changes_requested",
    "a corriger": "changes_requested",
    "à corriger": "changes_requested",
    "validated": "validated",
    "valide": "validated",
    "validé": "validated",
    "late": "late",
    "en retard": "late",
}

PRIORITY_ALIASES = {
    "low": "low",
    "faible": "low",
    "medium": "medium",
    "moyenne": "medium",
    "high": "high",
    "haute": "high",
    "urgent": "urgent",
}


def normalize_status(value: str | None) -> str:
    if not value:
        raise ApiError(400, "validation_error", "status is required.")

    normalized = STATUS_ALIASES.get(str(value).strip().lower())
    if not normalized:
        raise ApiError(400, "validation_error", "Unsupported task status.")
    return normalized


def normalize_priority(value: str | None) -> str:
    if not value:
        return "medium"

    normalized = PRIORITY_ALIASES.get(str(value).strip().lower())
    if not normalized:
        raise ApiError(400, "validation_error", "Unsupported task priority.")
    return normalized


def normalize_source(value: str | None) -> str:
    if not value:
        return "manual"

    text = str(value).strip().lower()
    if text not in {"manual", "ai_generated"}:
        raise ApiError(400, "validation_error", "Unsupported task source.")
    return text


def build_task_item(payload: dict, principal, created_at: str | None = None) -> dict:
    title = str(payload.get("title", "")).strip()
    description = str(payload.get("description", "")).strip()
    if not title or not description:
        raise ApiError(400, "validation_error", "title and description are required.")

    created_at = created_at or payload.get("createdAt")
    if not created_at:
        from common.utils import now_iso

        created_at = now_iso()

    return {
        "taskId": make_id("task"),
        "title": title,
        "description": description,
        "assignedTo": str(payload.get("assignedTo", "")).strip(),
        "assignedToName": str(payload.get("assignedToName", "")).strip(),
        "createdBy": principal.user_id,
        "createdByName": principal.full_name,
        "status": normalize_status(payload.get("status", "todo")),
        "priority": normalize_priority(payload.get("priority")),
        "category": str(payload.get("category", "")).strip(),
        "deadline": str(payload.get("deadline", "")).strip(),
        "source": normalize_source(payload.get("source")),
        "deliverable": str(payload.get("deliverable", "")).strip(),
        "validationCriteria": normalize_string_list(payload.get("validationCriteria", [])),
        "comments": [],
        "attachments": [],
        "createdAt": created_at,
        "updatedAt": created_at,
    }


def normalize_string_list(value) -> list[str]:
    if value is None:
        return []
    if not isinstance(value, list):
        raise ApiError(400, "validation_error", "validationCriteria must be a list.")
    return [str(item).strip() for item in value if str(item).strip()]


UPDATABLE_TASK_FIELDS = (
    "title",
    "description",
    "category",
    "deadline",
    "deliverable",
    "blockedReason",
    "assignedToName",
)


def apply_task_updates(task: dict, payload: dict, updated_at: str) -> dict:
    if not isinstance(payload, dict):
        raise ApiError(400, "validation_error", "Request body must be a JSON object.")

    for field in UPDATABLE_TASK_FIELDS:
        if field in payload:
            value = payload[field]
            task[field] = "" if value is None else str(value).strip()

    if "validationCriteria" in payload:
        task["validationCriteria"] = normalize_string_list(payload["validationCriteria"])

    if "priority" in payload:
        task["priority"] = normalize_priority(payload["priority"])

    if "status" in payload:
        task["status"] = normalize_status(payload["status"])

    if "assignedTo" in payload:
        task["assignedTo"] = str(payload["assignedTo"]).strip()

    task["updatedAt"] = updated_at
    return task


def can_view_task(principal, task: dict) -> bool:
    if principal.role == "admin":
        return True
    if principal.role == "instructor":
        return task.get("createdBy") == principal.user_id
    return task.get("assignedTo") == principal.user_id


def can_manage_task(principal, task: dict) -> bool:
    if principal.role == "admin":
        return True
    return principal.role == "instructor" and task.get("createdBy") == principal.user_id


def can_update_status(principal, task: dict) -> bool:
    if principal.role == "admin":
        return True
    if principal.role == "instructor":
        return task.get("createdBy") == principal.user_id
    return task.get("assignedTo") == principal.user_id


def can_comment_on_task(principal, task: dict) -> bool:
    return can_view_task(principal, task)


def build_comment(principal, message: str, created_at: str) -> dict:
    return {
        "commentId": make_id("comment"),
        "authorId": principal.user_id,
        "authorName": principal.full_name,
        "message": message,
        "createdAt": created_at,
    }


def build_attachment_metadata(task_id: str, principal, file_name: str, content_type: str, created_at: str) -> dict:
    return {
        "attachmentId": make_id("attachment"),
        "fileName": file_name,
        "contentType": content_type,
        "s3Key": build_s3_key(task_id, file_name),
        "uploadedBy": principal.user_id,
        "createdAt": created_at,
        "uploadStatus": "pending",
    }


def build_assignment_event(task: dict) -> dict:
    return {
        "notificationId": make_id("notification"),
        "userId": task["assignedTo"],
        "taskId": task["taskId"],
        "title": "New task assigned",
        "message": (
            f"Task '{task['title']}' was assigned"
            f"{' with deadline ' + task['deadline'] if task.get('deadline') else ''}."
        ),
        "createdAt": task["updatedAt"],
        "priority": task.get("priority", "medium"),
    }
