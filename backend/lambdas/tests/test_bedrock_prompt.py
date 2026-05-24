from common.bedrock_prompt import (
    build_generation_user_prompt,
    normalize_generated_tasks,
    parse_generated_tasks_text,
)


def test_build_generation_user_prompt_contains_domain():
    prompt = build_generation_user_prompt({"domain": "AWS / Terraform", "skills": ["S3", "IAM"]})
    assert "AWS / Terraform" in prompt
    assert "S3, IAM" in prompt


def test_parse_generated_tasks_text_handles_json():
    parsed = parse_generated_tasks_text('{"tasks":[{"title":"A","description":"B","validationCriteria":[]}]}')
    assert parsed["tasks"][0]["title"] == "A"


def test_normalize_generated_tasks_returns_ai_source():
    tasks = normalize_generated_tasks(
        [{"title": "A", "description": "B", "priority": "medium", "validationCriteria": []}]
    )
    assert tasks[0]["source"] == "ai_generated"
