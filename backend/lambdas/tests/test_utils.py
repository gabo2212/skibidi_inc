from common.utils import build_s3_key, safe_filename


def test_safe_filename_normalizes_spaces():
    assert safe_filename("proof file.pdf") == "proof-file.pdf"


def test_build_s3_key_uses_task_prefix():
    key = build_s3_key("task_123", "proof file.pdf", "20260524T120000Z")
    assert key == "tasks/task_123/20260524T120000Z-proof-file.pdf"
