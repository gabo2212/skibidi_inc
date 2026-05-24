import os

from common.auth import parse_principal
from common.http import ApiError, json_response, parse_json_body
from common.repository import AppRepository
from common.task_logic import (
    apply_task_updates,
    build_assignment_event,
    build_attachment_metadata,
    build_comment,
    build_task_item,
    can_comment_on_task,
    can_manage_task,
    can_update_status,
    can_view_task,
    normalize_status,
)


REPOSITORY = AppRepository(
    users_table_name=os.environ["USERS_TABLE_NAME"],
    tasks_table_name=os.environ["TASKS_TABLE_NAME"],
    notifications_table_name=os.environ["NOTIFICATIONS_TABLE_NAME"],
    attachments_bucket_name=os.environ["ATTACHMENTS_BUCKET_NAME"],
    assignments_topic_arn=os.environ["ASSIGNMENTS_TOPIC_ARN"],
)


def lambda_handler(event, context):
    try:
        principal = parse_principal(event)
        route_key = (event.get("httpMethod"), event.get("resource"))

        if route_key == ("POST", "/tasks"):
            return handle_create_task(event, principal)
        if route_key == ("GET", "/tasks"):
            return handle_list_tasks(event, principal)
        if route_key == ("GET", "/tasks/{id}"):
            return handle_get_task(event, principal)
        if route_key == ("PUT", "/tasks/{id}"):
            return handle_update_task(event, principal)
        if route_key == ("DELETE", "/tasks/{id}"):
            return handle_delete_task(event, principal)
        if route_key == ("PATCH", "/tasks/{id}/status"):
            return handle_patch_status(event, principal)
        if route_key == ("POST", "/tasks/{id}/comments"):
            return handle_post_comment(event, principal)
        if route_key == ("POST", "/tasks/{id}/attachment-url"):
            return handle_attachment_url(event, principal)
        if route_key == ("GET", "/tasks/{id}/attachments"):
            return handle_list_attachments(event, principal)
        if route_key == ("POST", "/tasks/{id}/assign"):
            return handle_assign_task(event, principal)
        if route_key == ("POST", "/auth/profile"):
            return handle_upsert_profile(event, principal)
        if route_key == ("GET", "/users/me"):
            return handle_get_me(event, principal)
        if route_key == ("GET", "/users/interns"):
            return handle_list_interns(event, principal)
        if route_key == ("GET", "/notifications"):
            return handle_list_notifications(event, principal)
        if route_key == ("PUT", "/notifications/{notificationId}/read"):
            return handle_mark_notification_read(event, principal)

        raise ApiError(404, "not_found", "Route not found.")
    except ApiError as exc:
        return json_response(exc.status_code, {"error": {"code": exc.code, "message": exc.message}})
    except Exception as exc:  # pragma: no cover - safety net
        return json_response(
            500,
            {
                "error": {
                    "code": "internal_error",
                    "message": "Unexpected server error.",
                    "details": str(exc),
                }
            },
        )


def handle_create_task(event, principal):
    principal.require_roles({"admin", "instructor"})
    payload = parse_json_body(event)

    task = build_task_item(payload, principal)
    REPOSITORY.put_task(task)

    if task.get("assignedTo"):
        REPOSITORY.publish_assignment_event(build_assignment_event(task))

    return json_response(201, {"task": task})


def handle_list_tasks(event, principal):
    query_params = event.get("queryStringParameters") or {}
    status_filter = query_params.get("status")

    if principal.role == "admin":
        tasks = REPOSITORY.scan_tasks()
    elif principal.role == "instructor":
        tasks = REPOSITORY.list_tasks_by_creator(principal.user_id)
    else:
        tasks = REPOSITORY.list_tasks_by_assignee(principal.user_id)

    visible_tasks = [task for task in tasks if can_view_task(principal, task)]
    if status_filter:
        normalized = normalize_status(status_filter)
        visible_tasks = [task for task in visible_tasks if task.get("status") == normalized]

    return json_response(200, {"tasks": visible_tasks})


def handle_get_task(event, principal):
    task = get_visible_task(event, principal)
    return json_response(200, {"task": task})


def handle_update_task(event, principal):
    task = get_visible_task(event, principal)
    if not can_manage_task(principal, task):
        raise ApiError(403, "forbidden", "You cannot update this task.")

    payload = parse_json_body(event)
    previous_assignee = task.get("assignedTo")
    apply_task_updates(task, payload, REPOSITORY.now_iso())

    REPOSITORY.put_task(task)

    new_assignee = task.get("assignedTo")
    if new_assignee and new_assignee != previous_assignee:
        REPOSITORY.publish_assignment_event(build_assignment_event(task))

    return json_response(200, {"task": task})


def handle_delete_task(event, principal):
    task = get_visible_task(event, principal)
    if not can_manage_task(principal, task):
        raise ApiError(403, "forbidden", "You cannot delete this task.")

    REPOSITORY.delete_task(task["taskId"])
    return json_response(200, {"deleted": True, "taskId": task["taskId"]})


def handle_patch_status(event, principal):
    task = get_visible_task(event, principal)
    if not can_update_status(principal, task):
        raise ApiError(403, "forbidden", "You cannot update this task status.")

    payload = parse_json_body(event)
    task["status"] = normalize_status(payload.get("status"))
    task["updatedAt"] = REPOSITORY.now_iso()
    if payload.get("blockedReason"):
        task["blockedReason"] = str(payload["blockedReason"]).strip()

    REPOSITORY.put_task(task)
    return json_response(200, {"task": task})


def handle_post_comment(event, principal):
    task = get_visible_task(event, principal)
    if not can_comment_on_task(principal, task):
        raise ApiError(403, "forbidden", "You cannot comment on this task.")

    payload = parse_json_body(event)
    message = str(payload.get("message", "")).strip()
    if not message:
        raise ApiError(400, "validation_error", "Comment message is required.")

    comment = build_comment(principal, message, REPOSITORY.now_iso())
    task.setdefault("comments", []).append(comment)
    task["updatedAt"] = REPOSITORY.now_iso()
    REPOSITORY.put_task(task)

    return json_response(201, {"comment": comment, "taskId": task["taskId"]})


def handle_attachment_url(event, principal):
    task = get_visible_task(event, principal)
    if not can_comment_on_task(principal, task):
        raise ApiError(403, "forbidden", "You cannot upload proof for this task.")

    payload = parse_json_body(event)
    file_name = str(payload.get("fileName", "")).strip()
    if not file_name:
        raise ApiError(400, "validation_error", "fileName is required.")

    content_type = str(payload.get("contentType", "application/octet-stream")).strip()
    attachment = build_attachment_metadata(task["taskId"], principal, file_name, content_type, REPOSITORY.now_iso())
    upload_url = REPOSITORY.generate_presigned_upload_url(attachment["s3Key"], content_type)

    task.setdefault("attachments", []).append(attachment)
    task["updatedAt"] = REPOSITORY.now_iso()
    REPOSITORY.put_task(task)

    return json_response(
        200,
        {
            "attachment": attachment,
            "uploadUrl": upload_url,
            "expiresIn": 900,
        },
    )


def handle_list_attachments(event, principal):
    task = get_visible_task(event, principal)
    attachments = task.get("attachments", []) or []
    return json_response(200, {"taskId": task["taskId"], "attachments": attachments})


def handle_assign_task(event, principal):
    task = get_visible_task(event, principal)
    if not can_manage_task(principal, task):
        raise ApiError(403, "forbidden", "You cannot assign this task.")

    payload = parse_json_body(event)
    assigned_to = str(payload.get("assignedTo", "")).strip()
    if not assigned_to:
        raise ApiError(400, "validation_error", "assignedTo is required.")

    task["assignedTo"] = assigned_to
    task["assignedToName"] = str(payload.get("assignedToName", "")).strip()
    task["updatedAt"] = REPOSITORY.now_iso()
    REPOSITORY.put_task(task)
    REPOSITORY.publish_assignment_event(build_assignment_event(task))

    return json_response(200, {"task": task})


def handle_upsert_profile(event, principal):
    payload = parse_json_body(event)
    existing = REPOSITORY.get_user(principal.user_id) or {}
    now = REPOSITORY.now_iso()

    user = {
        **existing,
        "userId": principal.user_id,
        "cognitoSub": principal.user_id,
        "email": principal.email or existing.get("email", ""),
        "fullName": str(payload.get("fullName", existing.get("fullName") or principal.full_name)).strip(),
        "role": principal.role,
        "updatedAt": now,
    }
    if "instructorId" in payload:
        user["instructorId"] = str(payload["instructorId"]).strip()
    user.setdefault("createdAt", now)

    REPOSITORY.put_user(user)
    return json_response(200, {"user": user})


def handle_get_me(event, principal):
    user = REPOSITORY.get_user(principal.user_id)
    if not user:
        user = {
            "userId": principal.user_id,
            "cognitoSub": principal.user_id,
            "email": principal.email,
            "fullName": principal.full_name,
            "role": principal.role,
        }
    return json_response(200, {"user": user})


def handle_list_interns(event, principal):
    principal.require_roles({"admin", "instructor"})
    if principal.role == "admin":
        instructor_filter = (event.get("queryStringParameters") or {}).get("instructorId")
        if instructor_filter:
            interns = REPOSITORY.list_interns_for_instructor(instructor_filter)
        else:
            interns = REPOSITORY.list_interns_for_instructor(principal.user_id)
    else:
        interns = REPOSITORY.list_interns_for_instructor(principal.user_id)
    return json_response(200, {"interns": interns})


def handle_list_notifications(event, principal):
    notifications = REPOSITORY.list_notifications_for_user(principal.user_id)
    notifications.sort(key=lambda item: item.get("createdAt", ""), reverse=True)
    return json_response(200, {"notifications": notifications})


def handle_mark_notification_read(event, principal):
    notification_id = (event.get("pathParameters") or {}).get("notificationId")
    if not notification_id:
        raise ApiError(400, "validation_error", "notificationId is required.")

    updated = REPOSITORY.mark_notification_read(principal.user_id, notification_id)
    if not updated:
        raise ApiError(404, "not_found", "Notification not found.")
    return json_response(200, {"notification": updated})


def get_visible_task(event, principal):
    task_id = (event.get("pathParameters") or {}).get("id")
    if not task_id:
        raise ApiError(400, "validation_error", "Task id is required.")

    task = REPOSITORY.get_task(task_id)
    if not task:
        raise ApiError(404, "not_found", "Task not found.")
    if not can_view_task(principal, task):
        raise ApiError(403, "forbidden", "You cannot access this task.")

    return task
