import json
import os

from common.repository import NotificationRepository


REPOSITORY = NotificationRepository(notifications_table_name=os.environ["NOTIFICATIONS_TABLE_NAME"])


def lambda_handler(event, context):
    processed = 0

    for record in event.get("Records", []):
        if record.get("EventSource") != "aws:sns":
            continue

        message = json.loads(record["Sns"]["Message"])
        notification = {
            "notificationId": message["notificationId"],
            "userId": message["userId"],
            "taskId": message["taskId"],
            "title": message["title"],
            "message": message["message"],
            "read": False,
            "createdAt": message["createdAt"],
        }
        REPOSITORY.put_notification(notification)
        processed += 1

    return {"status": "ok", "processed": processed}
