# Build Plan

This repository is being implemented in five validated checkpoints:

1. Repo foundation and documentation
2. Terraform infrastructure
3. Python Lambda backend API
4. Flutter mobile app
5. Integration glue and final documentation polish

## Constraints

- The uploaded AWS final-project brief is the source of truth.
- The Flutter client must send `Authorization: Bearer <access_token>`.
- The architecture stays intentionally boring and demo-friendly.
- No secrets or account-specific values are hardcoded.
- Terraform outputs drive runtime configuration for the mobile app.

## Deliverables

- Deployable Terraform stack
- Working Lambda backend
- Role-aware Flutter mobile app
- Demo helper scripts
- Teacher-ready documentation and screenshot checklist
