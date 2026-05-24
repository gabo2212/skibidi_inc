from common.auth import parse_groups, parse_principal


def test_parse_groups_from_string():
    assert parse_groups("[admin, instructor]") == ["admin", "instructor"]


def test_parse_principal_from_claims():
    event = {
        "requestContext": {
            "authorizer": {
                "claims": {
                    "sub": "user-1",
                    "email": "teacher@example.com",
                    "name": "Teacher",
                    "cognito:groups": "[instructor]",
                }
            }
        }
    }

    principal = parse_principal(event)
    assert principal.user_id == "user-1"
    assert principal.role == "instructor"
