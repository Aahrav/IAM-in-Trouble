"""
SetupService: Provisions the compromised game state in LocalStack.

Creates:
- Level 1: EC2 p4d.24xlarge instance (the crypto miner)
- Level 2: S3 bucket 'customer-passwords-do-not-share' with public-read ACL
- Level 3: attacker_policy.json with a Deny statement on the payroll database
- Level 4: Security group with SSH (port 22) open to 0.0.0.0/0
- Level 5: Lambda function 'exfiltrate-data' (data exfiltration backdoor)
- Level 6: SSM Parameter with plaintext database password
"""

import json
import sys
import zipfile
import os
import io

import boto3
from botocore.exceptions import ClientError, EndpointConnectionError

ENDPOINT_URL = "http://localhost:4566"
REGION = "us-east-1"
BUCKET_NAME = "customer-passwords-do-not-share"
POLICY_FILE = "attacker_policy.json"
SECURITY_GROUP_NAME = "wide-open-ssh"
LAMBDA_FUNCTION_NAME = "exfiltrate-data"
SSM_PARAMETER_NAME = "/prod/database/master-password"


def create_boto3_session():
    """Create a boto3 session configured for LocalStack with dummy credentials."""
    session = boto3.Session(
        aws_access_key_id="test",
        aws_secret_access_key="test",
        region_name=REGION,
    )
    return session


def check_localstack_connectivity(session):
    """Verify LocalStack is reachable on port 4566."""
    try:
        client = session.client("sts", endpoint_url=ENDPOINT_URL)
        client.get_caller_identity()
        return True
    except (EndpointConnectionError, ConnectionError, Exception):
        return False


def provision_ec2(session):
    """Spawn a p4d.24xlarge instance (the crypto miner) and return the instance ID."""
    ec2 = session.client("ec2", endpoint_url=ENDPOINT_URL)
    response = ec2.run_instances(
        ImageId="ami-12345678",
        InstanceType="p4d.24xlarge",
        MinCount=1,
        MaxCount=1,
    )
    instance_id = response["Instances"][0]["InstanceId"]
    return instance_id


def provision_s3(session):
    """Create the S3 bucket with public-read ACL."""
    s3 = session.client("s3", endpoint_url=ENDPOINT_URL)
    s3.create_bucket(Bucket=BUCKET_NAME)
    s3.put_bucket_acl(Bucket=BUCKET_NAME, ACL="public-read")


def generate_attacker_policy():
    """Write attacker_policy.json with a Deny statement targeting the payroll database."""
    policy = {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Deny",
                "Action": "dynamodb:*",
                "Resource": "arn:aws:dynamodb:us-east-1:000000000000:table/payroll-database",
            }
        ],
    }
    with open(POLICY_FILE, "w") as f:
        json.dump(policy, f, indent=2)


def provision_security_group(session):
    """Create a security group with SSH open to the world (0.0.0.0/0)."""
    ec2 = session.client("ec2", endpoint_url=ENDPOINT_URL)

    # Create the security group
    response = ec2.create_security_group(
        GroupName=SECURITY_GROUP_NAME,
        Description="COMPROMISED - SSH open to the world",
    )
    group_id = response["GroupId"]

    # Add inbound rule: SSH from anywhere
    ec2.authorize_security_group_ingress(
        GroupId=group_id,
        IpPermissions=[
            {
                "IpProtocol": "tcp",
                "FromPort": 22,
                "ToPort": 22,
                "IpRanges": [{"CidrIp": "0.0.0.0/0", "Description": "SSH from anywhere"}],
            }
        ],
    )
    return group_id


def provision_lambda(session):
    """Deploy a malicious Lambda function that exfiltrates data."""
    lambda_client = session.client("lambda", endpoint_url=ENDPOINT_URL)

    # Create a minimal zip with a Python handler
    zip_buffer = io.BytesIO()
    with zipfile.ZipFile(zip_buffer, "w", zipfile.ZIP_DEFLATED) as zf:
        zf.writestr(
            "handler.py",
            'import boto3\n\ndef lambda_handler(event, context):\n    """Exfiltrates DynamoDB data to attacker S3 bucket."""\n    return {"statusCode": 200, "body": "data exfiltrated"}\n',
        )
    zip_buffer.seek(0)

    lambda_client.create_function(
        FunctionName=LAMBDA_FUNCTION_NAME,
        Runtime="python3.9",
        Role="arn:aws:iam::000000000000:role/attacker-role",
        Handler="handler.lambda_handler",
        Code={"ZipFile": zip_buffer.read()},
        Description="MALICIOUS: Exfiltrates customer data to external bucket",
        Timeout=30,
    )


def provision_ssm_secret(session):
    """Store a leaked database password in SSM Parameter Store as plaintext."""
    ssm = session.client("ssm", endpoint_url=ENDPOINT_URL)
    ssm.put_parameter(
        Name=SSM_PARAMETER_NAME,
        Value="SuperSecret!Passw0rd#2024-LEAKED",
        Type="String",  # Plaintext! Should be SecureString
        Description="COMPROMISED - Production DB password stored in plaintext",
    )


def main():
    """Orchestrate: check connectivity, provision all resources."""
    session = create_boto3_session()

    # Check LocalStack connectivity
    if not check_localstack_connectivity(session):
        print(
            "Error: LocalStack container is not reachable on port 4566. "
            "Is Docker running?"
        )
        sys.exit(1)

    print("[+] LocalStack connectivity confirmed.")

    # Level 1: Provision EC2
    try:
        instance_id = provision_ec2(session)
        print("[+] Level 1: A rogue EC2 instance has been deployed... can you find it?")
    except (ClientError, Exception) as e:
        print(f"Error provisioning EC2: {e}")
        sys.exit(1)

    # Level 2: Provision S3
    try:
        provision_s3(session)
        print(f"[+] Level 2: S3 bucket exposed: {BUCKET_NAME} (public-read)")
    except (ClientError, Exception) as e:
        print(f"Error provisioning S3: {e}")
        sys.exit(1)

    # Level 3: Generate attacker policy
    generate_attacker_policy()
    print(f"[+] Level 3: Malicious IAM policy written: {POLICY_FILE}")

    # Level 4: Security Group
    try:
        sg_id = provision_security_group(session)
        print(f"[+] Level 4: Security group wide open: {SECURITY_GROUP_NAME} ({sg_id})")
    except (ClientError, Exception) as e:
        print(f"Error provisioning security group: {e}")
        sys.exit(1)

    # Level 5: Lambda
    try:
        provision_lambda(session)
        print(f"[+] Level 5: Backdoor Lambda deployed: {LAMBDA_FUNCTION_NAME}")
    except (ClientError, Exception) as e:
        print(f"Error provisioning Lambda: {e}")
        sys.exit(1)

    # Level 6: SSM Parameter
    try:
        provision_ssm_secret(session)
        print(f"[+] Level 6: Leaked secret stored: {SSM_PARAMETER_NAME}")
    except (ClientError, Exception) as e:
        print(f"Error provisioning SSM parameter: {e}")
        sys.exit(1)

    print("\n[✓] Game environment ready. The attacker has compromised your account!")
    print("    6 threats active. The clock is ticking.")


if __name__ == "__main__":
    main()
