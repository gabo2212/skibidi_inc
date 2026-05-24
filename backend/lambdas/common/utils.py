import json
import re
import uuid
from datetime import UTC, datetime


def now_iso() -> str:
    return datetime.now(tz=UTC).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def make_id(prefix: str) -> str:
    return f"{prefix}_{uuid.uuid4().hex[:16]}"


def safe_filename(file_name: str) -> str:
    sanitized = re.sub(r"[^A-Za-z0-9._-]+", "-", file_name).strip("-")
    return sanitized or "file"


def build_s3_key(task_id: str, file_name: str, timestamp: str | None = None) -> str:
    stamp = timestamp or datetime.now(tz=UTC).strftime("%Y%m%dT%H%M%SZ")
    return f"tasks/{task_id}/{stamp}-{safe_filename(file_name)}"


def extract_json_object(text: str) -> dict:
    cleaned = text.strip()
    if cleaned.startswith("```"):
        cleaned = cleaned.split("```", 1)[1]
        if cleaned.startswith("json"):
            cleaned = cleaned[4:]
        cleaned = cleaned.rsplit("```", 1)[0]
        cleaned = cleaned.strip()

    try:
        return json.loads(cleaned)
    except json.JSONDecodeError:
        start = cleaned.find("{")
        end = cleaned.rfind("}")
        if start == -1 or end == -1 or end <= start:
            raise
        return json.loads(cleaned[start : end + 1])
