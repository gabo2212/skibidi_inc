#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TERRAFORM_DIR="${TERRAFORM_DIR:-$ROOT_DIR/infra/terraform}"
OUTPUT_PATH="${OUTPUT_PATH:-$ROOT_DIR/mobile/assets/config/amplify_outputs.json}"

if ! command -v terraform >/dev/null 2>&1; then
  echo "terraform is required but was not found in PATH." >&2
  exit 1
fi

mkdir -p "$(dirname "$OUTPUT_PATH")"

RAW_OUTPUT="$(cd "$TERRAFORM_DIR" && terraform output -json)"

python3 - "$OUTPUT_PATH" <<'PY' <<<"$RAW_OUTPUT"
import json
import sys

output_path = sys.argv[1]
tf = json.load(sys.stdin)


def pick(*names):
    for name in names:
        if name in tf and tf[name].get("value") not in (None, ""):
            return tf[name]["value"]
    return ""


payload = {
    "version": "1",
    "auth": {
        "aws_region": pick("aws_region"),
        "user_pool_id": pick("cognito_user_pool_id"),
        "user_pool_client_id": pick("cognito_user_pool_client_id"),
        "username_attributes": ["email"],
        "standard_required_attributes": ["email"],
        "user_verification_types": ["email"],
        "unauthenticated_identities_enabled": False,
        "password_policy": {
            "min_length": 8,
            "require_lowercase": True,
            "require_uppercase": True,
            "require_numbers": True,
            "require_symbols": True,
        },
    },
    "custom": {
        "api_base_url": pick("api_gateway_url", "api_base_url"),
        "s3_bucket_name": pick("attachments_bucket_name", "s3_bucket_name"),
        "tasks_table_name": pick("tasks_table_name"),
        "notifications_table_name": pick("notifications_table_name"),
        "sns_topic_arn": pick("sns_topic_arn"),
    },
}

with open(output_path, "w", encoding="utf-8") as handle:
    json.dump(payload, handle, indent=2)
    handle.write("\n")
PY

echo "Wrote mobile config to $OUTPUT_PATH"
