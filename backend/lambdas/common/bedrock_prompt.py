from common.http import ApiError
from common.task_logic import normalize_priority, normalize_string_list
from common.utils import extract_json_object


def build_generation_system_prompt() -> str:
    return (
        "You are an assistant that drafts internship tasks for a mobile app. "
        "Return strict JSON only. The response must be shaped as "
        "{\"tasks\": [{\"title\": \"\", \"description\": \"\", \"priority\": \"medium\", "
        "\"category\": \"\", \"deliverable\": \"\", \"validationCriteria\": [\"\"], "
        "\"estimatedDuration\": \"\", \"difficulty\": \"\"}]}. "
        "Keep tasks concrete, scoped, and appropriate for the intern level."
    )


def build_generation_user_prompt(payload: dict) -> str:
    return "\n".join(
        [
            f"Intern name: {payload.get('internName', '')}",
            f"Internship domain: {payload.get('domain', '')}",
            f"Technical level: {payload.get('level', '')}",
            f"Week: {payload.get('week', '')}",
            f"Learning objective: {payload.get('objective', '')}",
            f"Targeted skills: {', '.join(payload.get('skills', [])) if isinstance(payload.get('skills'), list) else payload.get('skills', '')}",
            f"Estimated duration: {payload.get('duration', '')}",
            f"Deliverable type: {payload.get('deliverableType', '')}",
            "Return 3 task suggestions.",
        ]
    )


def parse_generated_tasks_text(text: str) -> dict:
    try:
        parsed = extract_json_object(text)
    except Exception as exc:
        raise ApiError(502, "bedrock_parse_error", "Bedrock did not return valid JSON.") from exc

    if not isinstance(parsed, dict):
        raise ApiError(502, "bedrock_parse_error", "Bedrock JSON payload must be an object.")
    return parsed


def normalize_generated_tasks(tasks: list[dict]) -> list[dict]:
    normalized_tasks = []
    for item in tasks:
        if not isinstance(item, dict):
            continue

        title = str(item.get("title", "")).strip()
        description = str(item.get("description", "")).strip()
        if not title or not description:
            continue

        normalized_tasks.append(
            {
                "title": title,
                "description": description,
                "priority": normalize_priority(item.get("priority", "medium")),
                "category": str(item.get("category", "")).strip(),
                "deliverable": str(item.get("deliverable", "")).strip(),
                "validationCriteria": normalize_string_list(item.get("validationCriteria", [])),
                "estimatedDuration": str(item.get("estimatedDuration", "")).strip(),
                "difficulty": str(item.get("difficulty", "")).strip(),
                "source": "ai_generated",
            }
        )

    if not normalized_tasks:
        raise ApiError(502, "bedrock_parse_error", "Bedrock did not return usable tasks.")
    return normalized_tasks
