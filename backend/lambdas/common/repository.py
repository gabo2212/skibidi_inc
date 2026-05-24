import json
from functools import cached_property

from common.utils import now_iso


class AppRepository:
    def __init__(
        self,
        users_table_name: str,
        tasks_table_name: str,
        notifications_table_name: str,
        attachments_bucket_name: str,
        assignments_topic_arn: str,
    ):
        self.users_table_name = users_table_name
        self.tasks_table_name = tasks_table_name
        self.notifications_table_name = notifications_table_name
        self.attachments_bucket_name = attachments_bucket_name
        self.assignments_topic_arn = assignments_topic_arn

    @cached_property
    def dynamodb(self):
        import boto3

        return boto3.resource("dynamodb")

    @cached_property
    def s3(self):
        import boto3

        return boto3.client("s3")

    @cached_property
    def sns(self):
        import boto3

        return boto3.client("sns")

    @cached_property
    def tasks_table(self):
        return self.dynamodb.Table(self.tasks_table_name)

    def put_task(self, task: dict) -> None:
        self.tasks_table.put_item(Item=task)

    def get_task(self, task_id: str) -> dict | None:
        response = self.tasks_table.get_item(Key={"taskId": task_id})
        return response.get("Item")

    def list_tasks_by_assignee(self, assignee_id: str) -> list[dict]:
        response = self.tasks_table.query(
            IndexName="assignedTo-index",
            KeyConditionExpression=self._key("assignedTo").eq(assignee_id),
        )
        return response.get("Items", [])

    def list_tasks_by_creator(self, creator_id: str) -> list[dict]:
        response = self.tasks_table.query(
            IndexName="createdBy-index",
            KeyConditionExpression=self._key("createdBy").eq(creator_id),
        )
        return response.get("Items", [])

    def scan_tasks(self) -> list[dict]:
        return self.tasks_table.scan().get("Items", [])

    def publish_assignment_event(self, event_payload: dict) -> None:
        self.sns.publish(
            TopicArn=self.assignments_topic_arn,
            Message=json.dumps(event_payload),
            Subject="InternTask assignment",
        )

    def generate_presigned_upload_url(self, s3_key: str, content_type: str) -> str:
        params = {
            "Bucket": self.attachments_bucket_name,
            "Key": s3_key,
            "ContentType": content_type,
        }
        return self.s3.generate_presigned_url(
            "put_object",
            Params=params,
            ExpiresIn=900,
        )

    def now_iso(self) -> str:
        return now_iso()

    @staticmethod
    def _key(name: str):
        from boto3.dynamodb.conditions import Key

        return Key(name)


class NotificationRepository:
    def __init__(self, notifications_table_name: str):
        self.notifications_table_name = notifications_table_name

    @cached_property
    def dynamodb(self):
        import boto3

        return boto3.resource("dynamodb")

    @cached_property
    def notifications_table(self):
        return self.dynamodb.Table(self.notifications_table_name)

    def put_notification(self, notification: dict) -> None:
        self.notifications_table.put_item(Item=notification)


class BedrockRepository:
    def __init__(self, model_id: str):
        self.model_id = model_id

    @cached_property
    def client(self):
        import boto3

        return boto3.client("bedrock-runtime")

    def generate_tasks(self, system_prompt: str, user_prompt: str) -> str:
        response = self.client.converse(
            modelId=self.model_id,
            system=[{"text": system_prompt}],
            messages=[
                {
                    "role": "user",
                    "content": [{"text": user_prompt}],
                }
            ],
            inferenceConfig={
                "temperature": 0.3,
                "maxTokens": 1200,
            },
        )
        return response["output"]["message"]["content"][0]["text"]
