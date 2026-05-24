#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TERRAFORM_DIR="${TERRAFORM_DIR:-$ROOT_DIR/infra/terraform}"
API_BASE_URL="${API_BASE_URL:-}"
ACCESS_TOKEN="${ACCESS_TOKEN:-}"
COMMAND="${1:-list}"

if [[ -z "$API_BASE_URL" ]]; then
  API_BASE_URL="$(cd "$TERRAFORM_DIR" && terraform output -raw api_base_url)"
fi

if [[ -z "$ACCESS_TOKEN" ]]; then
  echo "Set ACCESS_TOKEN to a valid Cognito access token before running this script." >&2
  exit 1
fi

curl_json() {
  local method="$1"
  local path="$2"
  local body="${3:-}"

  if [[ -n "$body" ]]; then
    curl -sS -X "$method" \
      -H "Authorization: Bearer $ACCESS_TOKEN" \
      -H "Content-Type: application/json" \
      "$API_BASE_URL$path" \
      -d "$body"
  else
    curl -sS -X "$method" \
      -H "Authorization: Bearer $ACCESS_TOKEN" \
      "$API_BASE_URL$path"
  fi
}

case "$COMMAND" in
  list)
    curl_json GET "/tasks"
    ;;
  generate)
    curl_json POST "/tasks/generate" '{
      "objective": "Prepare a first-week AWS onboarding plan",
      "domain": "Cloud",
      "internName": "Intern Demo",
      "level": "Junior",
      "skills": ["Terraform", "AWS", "Documentation"],
      "duration": "1 week",
      "deliverable": "Checklist and status summary"
    }'
    ;;
  create)
    curl_json POST "/tasks" '{
      "title": "Prepare onboarding checklist",
      "description": "Create an onboarding checklist for the first internship week.",
      "priority": "high",
      "category": "Operations",
      "deadline": "2026-06-01",
      "deliverable": "Shared checklist",
      "validationCriteria": "Instructor approves the final version",
      "assignedTo": "intern.demo@example.com",
      "assignedToName": "Intern Demo",
      "source": "manual"
    }'
    ;;
  *)
    echo "Usage: $0 [list|generate|create]" >&2
    exit 1
    ;;
esac

echo
