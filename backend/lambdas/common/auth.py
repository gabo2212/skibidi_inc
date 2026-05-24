from dataclasses import dataclass

from common.http import ApiError


@dataclass(frozen=True)
class Principal:
    user_id: str
    email: str
    full_name: str
    role: str
    groups: tuple[str, ...]

    def require_roles(self, allowed_roles: set[str]) -> None:
        if self.role not in allowed_roles:
            raise ApiError(403, "forbidden", "You are not allowed to perform this action.")


def parse_principal(event) -> Principal:
    claims = (
        event.get("requestContext", {})
        .get("authorizer", {})
        .get("claims", {})
    )
    if not claims:
        raise ApiError(401, "unauthorized", "Missing Cognito claims.")

    user_id = claims.get("sub")
    if not user_id:
        raise ApiError(401, "unauthorized", "Missing Cognito subject claim.")

    groups = parse_groups(claims.get("cognito:groups"))
    if "admin" in groups:
        role = "admin"
    elif "instructor" in groups:
        role = "instructor"
    else:
        role = "intern"

    full_name = (
        claims.get("name")
        or claims.get("preferred_username")
        or claims.get("email", "").split("@")[0]
        or user_id
    )

    return Principal(
        user_id=user_id,
        email=claims.get("email", ""),
        full_name=full_name,
        role=role,
        groups=tuple(groups),
    )


def parse_groups(raw_groups) -> list[str]:
    if raw_groups is None:
        return []
    if isinstance(raw_groups, list):
        return [str(item).strip() for item in raw_groups if str(item).strip()]

    text = str(raw_groups).strip()
    if not text:
        return []

    if text.startswith("[") and text.endswith("]"):
        text = text[1:-1]

    return [group.strip().strip("'").strip('"') for group in text.split(",") if group.strip()]
