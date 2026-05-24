#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TERRAFORM_DIR="${TERRAFORM_DIR:-$ROOT_DIR/infra/terraform}"

if [[ "${CONFIRM_DESTROY:-}" != "yes" ]]; then
  echo "Set CONFIRM_DESTROY=yes to run terraform destroy." >&2
  echo "Example: CONFIRM_DESTROY=yes ./scripts/teardown.sh" >&2
  exit 1
fi

cd "$TERRAFORM_DIR"
terraform destroy
