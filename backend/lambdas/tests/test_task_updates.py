from types import SimpleNamespace

import pytest

from common.http import ApiError
from common.task_logic import apply_task_updates


def _principal(role="instructor", user_id="teacher-1"):
    return SimpleNamespace(role=role, user_id=user_id, full_name="Teacher")


def test_apply_task_updates_changes_subset_of_fields():
    task = {
        "title": "Old",
        "description": "Old desc",
        "priority": "medium",
        "status": "todo",
        "validationCriteria": [],
    }
    updated = apply_task_updates(
        task,
        {"title": "New", "priority": "high"},
        "2026-05-24T13:00:00Z",
    )
    assert updated["title"] == "New"
    assert updated["priority"] == "high"
    assert updated["description"] == "Old desc"
    assert updated["updatedAt"] == "2026-05-24T13:00:00Z"


def test_apply_task_updates_normalizes_status_and_validation_criteria():
    task = {"status": "todo"}
    updated = apply_task_updates(
        task,
        {"status": "En cours", "validationCriteria": ["Step 1", " ", "Step 2"]},
        "2026-05-24T14:00:00Z",
    )
    assert updated["status"] == "in_progress"
    assert updated["validationCriteria"] == ["Step 1", "Step 2"]


def test_apply_task_updates_rejects_non_dict_payload():
    with pytest.raises(ApiError):
        apply_task_updates({}, ["not", "a", "dict"], "2026-05-24T15:00:00Z")
