from types import SimpleNamespace

from common.task_logic import build_task_item, can_view_task, normalize_status


def test_build_task_item_sets_defaults():
    principal = SimpleNamespace(user_id="teacher-1", full_name="Teacher")
    payload = {"title": "Task", "description": "Do thing", "priority": "moyenne"}

    task = build_task_item(payload, principal, created_at="2026-05-24T12:00:00Z")
    assert task["createdBy"] == "teacher-1"
    assert task["priority"] == "medium"
    assert task["status"] == "todo"


def test_intern_can_view_only_assigned_task():
    principal = SimpleNamespace(role="intern", user_id="intern-1")
    visible_task = {"assignedTo": "intern-1", "createdBy": "teacher-1"}
    hidden_task = {"assignedTo": "intern-2", "createdBy": "teacher-1"}

    assert can_view_task(principal, visible_task) is True
    assert can_view_task(principal, hidden_task) is False


def test_normalize_status_supports_french_label():
    assert normalize_status("En cours") == "in_progress"
