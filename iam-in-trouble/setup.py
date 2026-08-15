"""
SetupService: Provisions the compromised game state in LocalStack.

Creates:
- EC2 p4d.24xlarge instance (the crypto miner)
- S3 bucket 'customer-passwords-do-not-share' with public-read ACL
- attacker_policy.json with a Deny statement on the payroll database
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

    # Provision EC2
    try:
        instance_id = provision_ec2(session)
        print("[+] A rogue EC2 instance has been deployed... can you find it?")
    except (ClientError, Exception) as e:
        print(f"Error provisioning EC2: {e}")
        sys.exit(1)

    # Provision S3
    try:
        provision_s3(session)
        print(f"[+] S3 bucket created: {BUCKET_NAME} (public-read ACL)")
    except (ClientError, Exception) as e:
        print(f"Error provisioning S3: {e}")
        sys.exit(1)

    # Generate attacker policy
    generate_attacker_policy()
    print(f"[+] Malicious policy written: {POLICY_FILE}")

    print("\n[✓] Game environment ready. The attacker has compromised your account!")
    print("    🔍 A crypto miner is running somewhere... use your AWS CLI skills to find it.")
    print(f"    Bucket: {BUCKET_NAME}")
    print(f"    Policy: {POLICY_FILE}")


if __name__ == "__main__":
    main()
