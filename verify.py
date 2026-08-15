"""
VerifyService: Stateless level verification engine.

Accepts a level argument (1-6), queries the current state
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
SECURITY_GROUP_NAME = "wide-open-ssh"
LAMBDA_FUNCTION_NAME = "exfiltrate-data"
SSM_PARAMETER_NAME = "/prod/database/master-password"

VALID_LEVELS = ("1", "2", "3", "4", "5", "6")


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
        print("Valid levels: 1, 2, 3, 4, 5, 6")
        sys.exit(1)

    level_str = args[1]
    if level_str not in VALID_LEVELS:
        print(f"Error: Invalid level '{level_str}'. Must be 1, 2, 3, 4, 5, or 6.")
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


def verify_level_4(session):
    """
    Level 4: Check security group has no ingress rules allowing 0.0.0.0/0.

    Returns True if no ingress rule allows all traffic from anywhere, False otherwise.
    """
    try:
        ec2 = session.client("ec2", endpoint_url=ENDPOINT_URL)
        response = ec2.describe_security_groups(GroupNames=[SECURITY_GROUP_NAME])

        security_groups = response.get("SecurityGroups", [])
        if not security_groups:
            print("Error: Security group not found. Run setup.py first.")
            return False

        sg = security_groups[0]
        for permission in sg.get("IpPermissions", []):
            for ip_range in permission.get("IpRanges", []):
                if ip_range.get("CidrIp") == "0.0.0.0/0":
                    return False

        return True

    except (EndpointConnectionError, ConnectionError) as e:
        print(f"Error: Cannot connect to LocalStack: {e}")
        return False
    except ClientError as e:
        print(f"Error querying security groups: {e}")
        return False


def verify_level_5(session):
    """
    Level 5: Check that the malicious Lambda function has been deleted.

    Returns True if the function no longer exists, False otherwise.
    """
    try:
        lambda_client = session.client("lambda", endpoint_url=ENDPOINT_URL)
        lambda_client.get_function(FunctionName=LAMBDA_FUNCTION_NAME)
        # If we get here, the function still exists
        return False

    except ClientError as e:
        if e.response["Error"]["Code"] == "ResourceNotFoundException":
            # Function deleted — success!
            return True
        print(f"Error querying Lambda: {e}")
        return False
    except (EndpointConnectionError, ConnectionError) as e:
        print(f"Error: Cannot connect to LocalStack: {e}")
        return False


def verify_level_6(session):
    """
    Level 6: Check that the leaked SSM parameter has been deleted.

    Returns True if the parameter no longer exists, False otherwise.
    """
    try:
        ssm = session.client("ssm", endpoint_url=ENDPOINT_URL)
        ssm.get_parameter(Name=SSM_PARAMETER_NAME)
        # If we get here, the parameter still exists
        return False

    except ClientError as e:
        if e.response["Error"]["Code"] == "ParameterNotFound":
            # Parameter deleted — success!
            return True
        print(f"Error querying SSM: {e}")
        return False
    except (EndpointConnectionError, ConnectionError) as e:
        print(f"Error: Cannot connect to LocalStack: {e}")
        return False


# Dispatch table for level handlers
LEVEL_HANDLERS = {
    1: lambda session: verify_level_1(session),
    2: lambda session: verify_level_2(session),
    3: lambda session: verify_level_3(),
    4: lambda session: verify_level_4(session),
    5: lambda session: verify_level_5(session),
    6: lambda session: verify_level_6(session),
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
