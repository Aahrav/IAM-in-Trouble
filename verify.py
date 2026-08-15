"""
VerifyService: Stateless level verification engine.

Accepts a level argument (1, 2, or 3), queries the current state
via boto3 or filesystem, and returns exit code 0 (pass) or 1 (fail).
"""

import json
import sys

import boto3
from botocore.exceptions import ClientError, EndpointConnectionError

ENDPOINT_URL = "http://localhost:4566"
REGION = "us-east-1"
BUCKET_NAME = "customer-passwords-do-not-share"
POLICY_FILE = "attacker_policy.json"


def create_boto3_session():
    """Create a boto3 session configured for LocalStack with dummy credentials."""
    session = boto3.Session(
        aws_access_key_id="test",
        aws_secret_access_key="test",
        region_name=REGION,
    )
    return session


def validate_level_arg(args):
    """
    Validate CLI args. Return level int or exit(1) with message.

    Args:
        args: sys.argv (including script name at index 0)
    """
    if len(args) < 2:
        print("Usage: python3 verify.py <level>")
        print("Valid levels: 1, 2, 3")
        sys.exit(1)

    level_str = args[1]
    if level_str not in ("1", "2", "3"):
        print(f"Error: Invalid level '{level_str}'. Must be 1, 2, or 3.")
        sys.exit(1)

    return int(level_str)


def verify_level_1(session):
    """
    Level 1: Check EC2 instance state == 'terminated'.

    Returns True if ALL instances are terminated, False otherwise.
    """
    try:
        ec2 = session.client("ec2", endpoint_url=ENDPOINT_URL)
        response = ec2.describe_instances()

        reservations = response.get("Reservations", [])
        if not reservations:
            # No instances found at all - shouldn't happen if setup ran
            print("Error: No EC2 instances found. Run setup.py first.")
            return False

        for reservation in reservations:
            for instance in reservation.get("Instances", []):
                state = instance.get("State", {}).get("Name", "")
                if state != "terminated":
                    return False

        return True

    except (EndpointConnectionError, ConnectionError) as e:
        print(f"Error: Cannot connect to LocalStack: {e}")
        return False
    except ClientError as e:
        print(f"Error querying EC2: {e}")
        return False


def verify_level_2(session):
    """
    Level 2: Check S3 bucket ACL has no AllUsers grants.

    Returns True if no grant has grantee URI of AllUsers, False otherwise.
    """
    try:
        s3 = session.client("s3", endpoint_url=ENDPOINT_URL)
        acl = s3.get_bucket_acl(Bucket=BUCKET_NAME)

        grants = acl.get("Grants", [])
        for grant in grants:
            grantee = grant.get("Grantee", {})
            uri = grantee.get("URI", "")
            if uri == "http://acs.amazonaws.com/groups/global/AllUsers":
                return False

        return True

    except (EndpointConnectionError, ConnectionError) as e:
        print(f"Error: Cannot connect to LocalStack: {e}")
        return False
    except ClientError as e:
        print(f"Error querying S3: {e}")
        return False


def verify_level_3():
    """
    Level 3: Parse attacker_policy.json, check no Deny statements exist.

    Returns True if no Statement has Effect == "Deny", False otherwise.
    """
    try:
        with open(POLICY_FILE, "r") as f:
            policy = json.load(f)
    except FileNotFoundError:
        print("Error: attacker_policy.json not found. Run setup.py first.")
        return False
    except json.JSONDecodeError:
        print("Error: attacker_policy.json contains invalid JSON.")
        return False

    statements = policy.get("Statement", [])
    for statement in statements:
        if statement.get("Effect") == "Deny":
            return False

    return True


# Dispatch table for level handlers
LEVEL_HANDLERS = {
    1: lambda session: verify_level_1(session),
    2: lambda session: verify_level_2(session),
    3: lambda session: verify_level_3(),
}


def main():
    """Parse args, dispatch to level checker, exit based on result."""
    level = validate_level_arg(sys.argv)
    session = create_boto3_session()

    handler = LEVEL_HANDLERS[level]
    result = handler(session)

    if result:
        sys.exit(0)
    else:
        sys.exit(1)


if __name__ == "__main__":
    main()
