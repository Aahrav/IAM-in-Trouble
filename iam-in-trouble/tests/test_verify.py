"""
Property-based tests for VerifyService using Hypothesis.

Tests the core decision logic of each level verifier with generated inputs.
"""

import json
import sys
from unittest.mock import MagicMock, patch, mock_open

import pytest
from hypothesis import given, settings, assume
from hypothesis.strategies import (
    text,
    lists,
    fixed_dictionaries,
    sampled_from,
    just,
    one_of,
    booleans,
    dictionaries,
)

# Add parent directory to path so we can import verify module
sys.path.insert(0, "/home/aahrav/kiro-hack/iam-in-trouble")

import verify


# ============================================================================
# Feature: iam-in-trouble, Property 1: EC2 Verification Decision
# For any EC2 instance state string, verify_level_1 SHALL return True iff
# the state equals "terminated"; for any other state, it SHALL return False.
# Validates: Requirements 2.3, 2.4
# ============================================================================

@pytest.mark.property
@settings(max_examples=200)
@given(state=text())
def test_ec2_verification_decision(state):
    """Property 1: exit code 0 iff state == 'terminated'."""
    session = MagicMock()
    ec2_client = MagicMock()
    session.client.return_value = ec2_client

    ec2_client.describe_instances.return_value = {
        "Reservations": [
            {
                "Instances": [
                    {
                        "InstanceId": "i-abc123",
                        "State": {"Name": state, "Code": 48 if state == "terminated" else 16},
                    }
                ]
            }
        ]
    }

    result = verify.verify_level_1(session)
    expected = state == "terminated"
    assert result == expected, f"state={state!r}, got {result}, expected {expected}"


# ============================================================================
# Feature: iam-in-trouble, Property 2: S3 ACL Verification Decision
# For any valid S3 ACL grant list, verify_level_2 SHALL return True iff no
# grant has grantee URI equal to AllUsers; otherwise it SHALL return False.
# Validates: Requirements 3.2, 3.3
# ============================================================================

ALL_USERS_URI = "http://acs.amazonaws.com/groups/global/AllUsers"

# Strategy: generate a list of ACL grants with random grantee URIs
grant_uri_strategy = one_of(
    just(ALL_USERS_URI),
    just("http://acs.amazonaws.com/groups/global/AuthenticatedUsers"),
    just(""),
    text(min_size=1, max_size=100),
)

grant_strategy = fixed_dictionaries({
    "Grantee": fixed_dictionaries({
        "Type": just("Group"),
        "URI": grant_uri_strategy,
    }),
    "Permission": sampled_from(["READ", "WRITE", "FULL_CONTROL"]),
})


@pytest.mark.property
@settings(max_examples=200)
@given(grants=lists(grant_strategy, min_size=0, max_size=10))
def test_s3_acl_verification_decision(grants):
    """Property 2: exit code 0 iff no grant URI equals AllUsers."""
    session = MagicMock()
    s3_client = MagicMock()
    session.client.return_value = s3_client

    s3_client.get_bucket_acl.return_value = {
        "Owner": {"ID": "owner123"},
        "Grants": grants,
    }

    result = verify.verify_level_2(session)

    has_all_users = any(
        g.get("Grantee", {}).get("URI") == ALL_USERS_URI for g in grants
    )
    expected = not has_all_users
    assert result == expected, f"grants={grants!r}, got {result}, expected {expected}"


# ============================================================================
# Feature: iam-in-trouble, Property 3: IAM Policy Verification Decision
# For any valid JSON IAM policy document, verify_level_3 SHALL return True iff
# no Statement has "Effect" equal to "Deny"; otherwise it SHALL return False.
# Validates: Requirements 4.2, 4.3
# ============================================================================

effect_strategy = one_of(
    just("Deny"),
    just("Allow"),
    text(min_size=1, max_size=20),
)

statement_strategy = fixed_dictionaries({
    "Effect": effect_strategy,
    "Action": just("dynamodb:*"),
    "Resource": just("arn:aws:dynamodb:us-east-1:000000000000:table/test"),
})


@pytest.mark.property
@settings(max_examples=200)
@given(statements=lists(statement_strategy, min_size=0, max_size=5))
def test_iam_policy_verification_decision(statements):
    """Property 3: exit code 0 iff no Statement has Effect == 'Deny'."""
    policy = {
        "Version": "2012-10-17",
        "Statement": statements,
    }
    policy_json = json.dumps(policy)

    with patch("builtins.open", mock_open(read_data=policy_json)):
        result = verify.verify_level_3()

    has_deny = any(s.get("Effect") == "Deny" for s in statements)
    expected = not has_deny
    assert result == expected, f"statements={statements!r}, got {result}, expected {expected}"


# ============================================================================
# Feature: iam-in-trouble, Property 4: Invalid Level Argument Rejection
# For any string that is not "1", "2", or "3", calling validate_level_arg
# SHALL exit with code 1.
# Validates: Requirements 9.2
# ============================================================================

@pytest.mark.property
@settings(max_examples=200)
@given(arg=text())
def test_invalid_level_argument_rejection(arg):
    """Property 4: any non-valid level arg exits with code 1."""
    assume(arg not in ("1", "2", "3"))

    with pytest.raises(SystemExit) as exc_info:
        verify.validate_level_arg(["verify.py", arg])

    assert exc_info.value.code == 1


# ============================================================================
# Additional unit tests for edge cases
# ============================================================================

@pytest.mark.unit
def test_no_argument_exits_with_usage():
    """No argument prints usage and exits 1."""
    with pytest.raises(SystemExit) as exc_info:
        verify.validate_level_arg(["verify.py"])
    assert exc_info.value.code == 1


@pytest.mark.unit
def test_valid_levels_accepted():
    """Valid levels 1, 2, 3 are accepted."""
    assert verify.validate_level_arg(["verify.py", "1"]) == 1
    assert verify.validate_level_arg(["verify.py", "2"]) == 2
    assert verify.validate_level_arg(["verify.py", "3"]) == 3


@pytest.mark.unit
def test_level_3_missing_file():
    """Missing attacker_policy.json returns False."""
    with patch("builtins.open", side_effect=FileNotFoundError()):
        result = verify.verify_level_3()
    assert result is False


@pytest.mark.unit
def test_level_3_invalid_json():
    """Invalid JSON in attacker_policy.json returns False."""
    with patch("builtins.open", mock_open(read_data="not valid json {")):
        result = verify.verify_level_3()
    assert result is False


@pytest.mark.unit
def test_level_3_no_deny_passes():
    """Policy with only Allow statements passes."""
    policy = json.dumps({
        "Version": "2012-10-17",
        "Statement": [{"Effect": "Allow", "Action": "*", "Resource": "*"}],
    })
    with patch("builtins.open", mock_open(read_data=policy)):
        result = verify.verify_level_3()
    assert result is True


@pytest.mark.unit
def test_level_3_with_deny_fails():
    """Policy with a Deny statement fails."""
    policy = json.dumps({
        "Version": "2012-10-17",
        "Statement": [{"Effect": "Deny", "Action": "dynamodb:*", "Resource": "*"}],
    })
    with patch("builtins.open", mock_open(read_data=policy)):
        result = verify.verify_level_3()
    assert result is False


@pytest.mark.unit
def test_level_1_terminated_passes():
    """EC2 in terminated state passes."""
    session = MagicMock()
    ec2_client = MagicMock()
    session.client.return_value = ec2_client
    ec2_client.describe_instances.return_value = {
        "Reservations": [{"Instances": [{"State": {"Name": "terminated"}}]}]
    }
    assert verify.verify_level_1(session) is True


@pytest.mark.unit
def test_level_1_running_fails():
    """EC2 in running state fails."""
    session = MagicMock()
    ec2_client = MagicMock()
    session.client.return_value = ec2_client
    ec2_client.describe_instances.return_value = {
        "Reservations": [{"Instances": [{"State": {"Name": "running"}}]}]
    }
    assert verify.verify_level_1(session) is False


@pytest.mark.unit
def test_level_2_private_acl_passes():
    """S3 bucket with no AllUsers grants passes."""
    session = MagicMock()
    s3_client = MagicMock()
    session.client.return_value = s3_client
    s3_client.get_bucket_acl.return_value = {
        "Grants": [
            {"Grantee": {"Type": "CanonicalUser", "ID": "owner"}, "Permission": "FULL_CONTROL"}
        ]
    }
    assert verify.verify_level_2(session) is True


@pytest.mark.unit
def test_level_2_public_acl_fails():
    """S3 bucket with AllUsers grant fails."""
    session = MagicMock()
    s3_client = MagicMock()
    session.client.return_value = s3_client
    s3_client.get_bucket_acl.return_value = {
        "Grants": [
            {
                "Grantee": {
                    "Type": "Group",
                    "URI": "http://acs.amazonaws.com/groups/global/AllUsers",
                },
                "Permission": "READ",
            }
        ]
    }
    assert verify.verify_level_2(session) is False
