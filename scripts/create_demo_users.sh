#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TERRAFORM_DIR="${TERRAFORM_DIR:-$ROOT_DIR/infra/terraform}"
USER_POOL_ID="${USER_POOL_ID:-}"
DEFAULT_PASSWORD="${DEFAULT_PASSWORD:-Password123!}"

if ! command -v aws >/dev/null 2>&1; then
  echo "aws CLI is required but was not found in PATH." >&2
  exit 1
fi

if [[ -z "$USER_POOL_ID" ]]; then
  USER_POOL_ID="$(cd "$TERRAFORM_DIR" && terraform output -raw cognito_user_pool_id)"
fi

create_user() {
  local email="$1"
  local group="$2"
  local name="$3"

  if aws cognito-idp admin-get-user \
    --user-pool-id "$USER_POOL_ID" \
    --username "$email" >/dev/null 2>&1; then
    echo "User already exists: $email"
  else
    aws cognito-idp admin-create-user \
      --user-pool-id "$USER_POOL_ID" \
      --username "$email" \
      --message-action SUPPRESS \
      --user-attributes \
        Name=email,Value="$email" \
        Name=email_verified,Value=true \
        Name=name,Value="$name" >/dev/null
    echo "Created user: $email"
  fi

  aws cognito-idp admin-set-user-password \
    --user-pool-id "$USER_POOL_ID" \
    --username "$email" \
    --password "$DEFAULT_PASSWORD" \
    --permanent >/dev/null

  aws cognito-idp admin-add-user-to-group \
    --user-pool-id "$USER_POOL_ID" \
    --username "$email" \
    --group-name "$group" >/dev/null

  echo "Configured $email in group $group"
}

create_user "admin.demo@example.com" "admin" "Admin Demo"
create_user "instructor.demo@example.com" "instructor" "Instructor Demo"
create_user "intern.demo@example.com" "intern" "Intern Demo"

echo "Demo users are ready."
echo "Permanent password: $DEFAULT_PASSWORD"
