import json


class ApiError(Exception):
    def __init__(self, status_code: int, code: str, message: str):
        super().__init__(message)
        self.status_code = status_code
        self.code = code
        self.message = message


def json_response(status_code: int, payload: dict) -> dict:
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
        },
        "body": json.dumps(payload),
    }


def parse_json_body(event) -> dict:
    raw_body = event.get("body")
    if raw_body in (None, ""):
        return {}

    if event.get("isBase64Encoded"):
        raise ApiError(400, "invalid_request", "Base64-encoded request bodies are not supported.")

    try:
        parsed = json.loads(raw_body)
    except json.JSONDecodeError as exc:
        raise ApiError(400, "invalid_json", "Request body must be valid JSON.") from exc

    if not isinstance(parsed, dict):
        raise ApiError(400, "invalid_request", "Request body must be a JSON object.")

    return parsed
