import os

from common.auth import parse_principal
from common.bedrock_prompt import (
    build_generation_system_prompt,
    build_generation_user_prompt,
    normalize_generated_tasks,
    parse_generated_tasks_text,
)
from common.http import ApiError, json_response, parse_json_body
from common.repository import BedrockRepository


BEDROCK = BedrockRepository(model_id=os.environ["BEDROCK_MODEL_ID"])


def lambda_handler(event, context):
    try:
        principal = parse_principal(event)
        principal.require_roles({"admin", "instructor"})

        payload = parse_json_body(event)
        prompt = build_generation_user_prompt(payload)
        raw_text = BEDROCK.generate_tasks(
            system_prompt=build_generation_system_prompt(),
            user_prompt=prompt,
        )
        parsed = parse_generated_tasks_text(raw_text)
        tasks = normalize_generated_tasks(parsed.get("tasks", []))

        return json_response(200, {"tasks": tasks, "rawText": raw_text})
    except ApiError as exc:
        return json_response(exc.status_code, {"error": {"code": exc.code, "message": exc.message}})
    except Exception as exc:  # pragma: no cover - safety net
        return json_response(
            502,
            {
                "error": {
                    "code": "bedrock_error",
                    "message": "Task generation failed.",
                    "details": str(exc),
                }
            },
        )
