# IAM In Trouble — Complete Game Guide

## What Is This Game?

You're an on-call SRE (Site Reliability Engineer) woken up at 2:00 AM. Your company's AWS account has been hacked. An attacker:
1. Launched a GPU server to mine cryptocurrency (costing $32.77/hour)
2. Made a customer database publicly readable (2.3 million records exposed)
3. Locked employees out of the payroll system with a malicious policy
4. Opened SSH access to the entire internet on your servers
5. Deployed a backdoor function to steal data on-demand
6. Stored your database password in plaintext for easy retrieval

You must fix all 6 problems using real AWS CLI commands before the company goes bankrupt.

---

## Game Features

### The Bankrupt Counter
A live-updating money counter ticks at the top of your terminal showing how much the attack is costing. It starts at $32.50 and accelerates over time. Random spikes happen. After 30 seconds, the rate increases automatically.

### Hints (`./hint.sh <level>`)
If you're stuck, you can ask for help — but it costs you. Each hint accelerates the bankrupt counter:
- 1st hint: rate jumps to $2.00/tick
- 2nd hint: rate jumps to $5.00/tick
- 3rd+ hint: rate jumps to $10.00/tick

Hints explain WHAT happened and give you KEY CONCEPTS, but don't give you the exact answer. You still need to construct the commands yourself.

### Timer & Scoring
A timer runs from game start. When you complete all 6 levels, you get a grade:
| Time | Grade |
|------|-------|
| Under 2 minutes | Senior SRE — You crushed it! |
| Under 5 minutes | Junior SRE — Not bad, room to improve |
| Over 5 minutes | FIRED — Too slow, the company went bankrupt |

### Verification (`./verify.sh <level>`)
After you fix something, run verify to check your work. It shows:
- Green "THREAT NEUTRALIZED" if you solved it
- Red "NOT YET RESOLVED" with a short nudge if you haven't
- A progress bar showing how many levels you've cleared (0/6, 1/6, etc.)

---

## Prerequisites

### 1. Docker (for the fake AWS backend)
```bash
sudo docker compose up -d
```
Wait ~15 seconds for LocalStack to start up.

### 2. AWS CLI configured
```bash
aws configure
```
Enter:
- Access Key: `test`
- Secret Key: `test`
- Region: `us-east-1`
- Output: `json`

### 3. Test the connection
```bash
aws --endpoint-url=http://localhost:4566 sts get-caller-identity
```
You should see Account: 000000000000.

---

## Starting the Game

```bash
cd ~/kiro-hack
python3 setup.py        # Provisions the hacked environment
./start_game.sh         # Launches the game (briefing + counter)
```

You'll see:
1. A boot sequence animation
2. A PagerDuty alert ASCII art
3. The incident briefing (timeline of the attack)
4. A mission panel showing your 6 objectives
5. The bankrupt counter starts ticking in the top bar

---

## Available Commands During Gameplay

| Command | What it does |
|---------|-------------|
| `./verify.sh 1` | Check if Level 1 is solved |
| `./verify.sh 2` | Check if Level 2 is solved |
| `./verify.sh 3` | Check if Level 3 is solved |
| `./verify.sh 4` | Check if Level 4 is solved |
| `./verify.sh 5` | Check if Level 5 is solved |
| `./verify.sh 6` | Check if Level 6 is solved |
| `./hint.sh 1` | Get guided help for Level 1 (costs you!) |
| `./hint.sh 2` | Get guided help for Level 2 (costs you!) |
| `./hint.sh 3` | Get guided help for Level 3 (costs you!) |
| `./hint.sh 4` | Get guided help for Level 4 (costs you!) |
| `./hint.sh 5` | Get guided help for Level 5 (costs you!) |
| `./hint.sh 6` | Get guided help for Level 6 (costs you!) |
| `./game.sh status` | Check game status |
| `./game.sh stop` | Stop the game / kill the counter |

---

## Level 1: Kill the Crypto Miner (EC2)

### The Problem
An attacker launched a p4d.24xlarge GPU instance (8x NVIDIA A100 GPUs) to mine Dogecoin. It costs $32.77/hour and is actively draining your account.

### Key Concepts
- **EC2** = Elastic Compute Cloud = virtual servers (machines) in AWS
- **Instance** = a single running server/machine
- **InstanceId** = unique identifier for a server (starts with `i-`)
- **InstanceType** = the size/power of the server (p4d.24xlarge = massive GPU machine)
- **terminate** = permanently shut down and delete a server (can't be undone)
- **describe** = look up information about resources (read-only, doesn't change anything)
- **--endpoint-url** = tells AWS CLI to talk to LocalStack (fake AWS) instead of real AWS

### How to Solve

**Step 1: Find the running instance**

You need to list all EC2 instances to find the rogue one:
```bash
aws --endpoint-url=http://localhost:4566 ec2 describe-instances
```

This outputs a big JSON blob. Look for:
- `"InstanceId": "i-xxxxxxxxxx"` — the server's unique ID (you need this!)
- `"InstanceType": "p4d.24xlarge"` — confirms it's the crypto miner
- `"State": {"Name": "running"}` — confirms it's still active

**Pro tip** — filter the output to see just the important parts:
```bash
aws --endpoint-url=http://localhost:4566 ec2 describe-instances | grep -E "InstanceId|InstanceType|\"Name\""
```

**Step 2: Terminate (kill) the instance**

Replace `<INSTANCE_ID>` with the actual ID you found (e.g., `i-abc123def456`):
```bash
aws --endpoint-url=http://localhost:4566 ec2 terminate-instances --instance-ids <INSTANCE_ID>
```

**What this does:** Sends a "shut down permanently" signal to that specific server. The state changes from "running" to "terminated". The crypto miner stops. Money stops draining.

**Step 3: Verify**
```bash
./verify.sh 1
```

---

## Level 2: Lock Down the S3 Bucket

### The Problem
An S3 bucket called `customer-passwords-do-not-share` has been set to `public-read`. Anyone on the internet can download 2.3 million customer records right now.

### Key Concepts
- **S3** = Simple Storage Service = cloud file storage (like Dropbox/Google Drive but for servers)
- **Bucket** = a container for files (like a top-level folder)
- **ACL** = Access Control List = the rules that say WHO can access the bucket
- **public-read** = everyone on the internet can download files from this bucket
- **private** = only the account owner can access files (what we want!)
- **s3api** = the low-level S3 commands (needed for ACL changes)
- **put-bucket-acl** = the command to change a bucket's access permissions

### How to Solve

**Step 1: (Optional) See the current permissions**
```bash
aws --endpoint-url=http://localhost:4566 s3api get-bucket-acl --bucket customer-passwords-do-not-share
```

In the output, you'll see a "Grants" section with:
- `"URI": "http://acs.amazonaws.com/groups/global/AllUsers"` — this means THE ENTIRE PUBLIC INTERNET has access
- `"Permission": "READ"` — they can download everything

**Step 2: Set the bucket to private**
```bash
aws --endpoint-url=http://localhost:4566 s3api put-bucket-acl --bucket customer-passwords-do-not-share --acl private
```

**What this does:** Replaces the ACL with "private" — removes all public access grants. Only the account owner (you) can now access the files. The 2.3 million customer records are safe.

**Step 3: Verify**
```bash
./verify.sh 2
```

---

## Level 3: Remove the Malicious IAM Policy

### The Problem
The attacker created a file called `attacker_policy.json` with a "Deny" rule that BLOCKS all access to the payroll database. Nobody in the company can get paid until you fix this.

### Key Concepts
- **IAM** = Identity & Access Management = AWS's permission system
- **Policy** = a JSON document that defines what actions are allowed or denied
- **Statement** = a single rule inside a policy
- **"Effect": "Allow"** = this rule PERMITS an action
- **"Effect": "Deny"** = this rule BLOCKS an action (overrides Allow!)
- **JSON** = a text format for data. Uses `{}` for objects and `[]` for lists
- **nano** = a simple terminal text editor (Ctrl+O to save, Ctrl+X to exit)

### How to Solve

**Step 1: Look at the malicious file**
```bash
cat attacker_policy.json
```
You'll see:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Action": "dynamodb:*",
      "Resource": "arn:aws:dynamodb:us-east-1:000000000000:table/payroll-database"
    }
  ]
}
```

**Reading this policy:**
- `"Effect": "Deny"` = BLOCK access
- `"Action": "dynamodb:*"` = block ALL database operations
- `"Resource": "...payroll-database"` = specifically on the payroll table

So this policy says: "Block everyone from doing anything to the payroll database."

**Step 2: Edit the file to remove the Deny block**
```bash
nano attacker_policy.json
```

Delete everything inside the `Statement` array so it becomes:
```json
{
  "Version": "2012-10-17",
  "Statement": []
}
```

**How to edit in nano:**
1. Use arrow keys to navigate
2. Use `Backspace`/`Delete` to remove text
3. Type new text normally
4. `Ctrl+O` → press `Enter` to save
5. `Ctrl+X` to exit

**Important:** The file MUST remain valid JSON. Make sure:
- All `{` have a matching `}`
- All `[` have a matching `]`
- Strings are in double quotes `""`

**Step 3: Verify**
```bash
./verify.sh 3
```

---

## Level 4: Close the Open Security Group

### The Problem
The attacker created a Security Group called `wide-open-ssh` that allows SSH access (port 22) from `0.0.0.0/0` — meaning ANYONE on the internet can try to log into your servers. This enables brute-force password attacks.

### Key Concepts
- **Security Group** = a virtual firewall that controls traffic to/from your servers
- **Ingress** = inbound traffic (connections coming IN to your server)
- **Egress** = outbound traffic (connections going OUT from your server)
- **Port 22** = SSH (Secure Shell) — remote terminal access to a server
- **0.0.0.0/0** = a CIDR notation meaning "every IP address on the internet"
- **GroupId** = unique identifier for a security group (starts with `sg-`)
- **revoke** = remove/take back a permission that was granted
- **CIDR** = a way to express IP ranges (e.g., `10.0.0.0/8` = all IPs starting with 10)

### How to Solve

**Step 1: Find the security group and its ID**

List all security groups:
```bash
aws --endpoint-url=http://localhost:4566 ec2 describe-security-groups
```

Look for:
- `"GroupName": "wide-open-ssh"` — that's the dangerous one
- `"GroupId": "sg-xxxxxxxxxx"` — you need this ID
- Under `"IpPermissions"` you'll see the rule allowing port 22 from 0.0.0.0/0

**Pro tip** — filter to just see the group you need:
```bash
aws --endpoint-url=http://localhost:4566 ec2 describe-security-groups --group-names wide-open-ssh
```

**Step 2: Revoke (remove) the dangerous ingress rule**

Replace `<GROUP_ID>` with the actual sg-xxx ID you found:
```bash
aws --endpoint-url=http://localhost:4566 ec2 revoke-security-group-ingress --group-id <GROUP_ID> --protocol tcp --port 22 --cidr 0.0.0.0/0
```

**What each flag means:**
- `revoke-security-group-ingress` = remove an inbound rule
- `--group-id` = which security group to modify
- `--protocol tcp` = the rule uses TCP protocol
- `--port 22` = the rule is for port 22 (SSH)
- `--cidr 0.0.0.0/0` = the rule allows connections from everywhere

**What this does:** Removes the rule that was letting the entire internet try to SSH into your servers. The firewall is now closed.

**Step 3: Verify**
```bash
./verify.sh 4
```

---

## Level 5: Delete the Backdoor Lambda Function

### The Problem
The attacker deployed an AWS Lambda function called `exfiltrate-data`. This is a serverless script that, when triggered, copies your customer data and sends it to the attacker's own storage. It's sitting there like a time bomb.

### Key Concepts
- **Lambda** = AWS's serverless compute service — run code without managing servers
- **Function** = a piece of code uploaded to Lambda that runs on-demand
- **Serverless** = you don't manage the server; AWS runs your code when triggered
- **Exfiltrate** = secretly copy and steal data
- **FunctionName** = the name given to a Lambda function (used to identify/manage it)
- **list-functions** = shows all Lambda functions in your account
- **delete-function** = permanently removes a Lambda function

### How to Solve

**Step 1: Find the malicious Lambda function**

List all Lambda functions:
```bash
aws --endpoint-url=http://localhost:4566 lambda list-functions
```

Look for:
- `"FunctionName"` — find the one with a suspicious name related to data theft
- `"Description"` — it may describe malicious intent
- `"Runtime"` — shows what language it's written in

**Step 2: Delete the malicious function**

Once you know the function name, delete it:
```bash
aws --endpoint-url=http://localhost:4566 lambda delete-function --function-name <FUNCTION_NAME>
```

Replace `<FUNCTION_NAME>` with the name you found from `list-functions`.

**What this does:** Permanently removes the function from AWS. The attacker can no longer trigger it to steal data. The backdoor is gone.

**Step 3: Verify**
```bash
./verify.sh 5
```

---

## Level 6: Delete the Leaked Secret from SSM

### The Problem
The attacker stored your production database master password in AWS SSM Parameter Store as PLAINTEXT (not encrypted). This means they can retrieve it anytime and log into your database directly. They have the keys to your kingdom.

### Key Concepts
- **SSM** = Systems Manager — a service for managing configuration and secrets
- **Parameter Store** = a part of SSM that stores key-value pairs (like settings and passwords)
- **Parameter** = a named value stored in Parameter Store (has a path-like name)
- **String type** = stored in PLAINTEXT (bad for passwords! should be SecureString)
- **SecureString type** = stored encrypted (the safe way to store secrets)
- **describe-parameters** = lists all parameters (names and metadata, not values)
- **get-parameter** = retrieves a specific parameter's value
- **delete-parameter** = permanently removes a parameter

### How to Solve

**Step 1: Find the leaked parameter**

List all parameters to find the suspicious one:
```bash
aws --endpoint-url=http://localhost:4566 ssm describe-parameters
```

Look for:
- `"Name"` — the parameter's path (like a file path: /something/something)
- `"Description"` — may reveal it's compromised
- `"Type": "String"` — this means it's stored in PLAINTEXT (dangerous for passwords!)

**Optional:** See the actual leaked password value:
```bash
aws --endpoint-url=http://localhost:4566 ssm get-parameter --name <PARAMETER_NAME>
```

**Step 2: Delete the leaked parameter**

Once you know the parameter name/path, delete it:
```bash
aws --endpoint-url=http://localhost:4566 ssm delete-parameter --name <PARAMETER_NAME>
```

Replace `<PARAMETER_NAME>` with the full path you found (e.g., `/something/something/something`).

**What this does:** Permanently removes the password from Parameter Store. The attacker can no longer retrieve it. (In real life, you'd also rotate the password immediately.)

**Step 3: Verify**
```bash
./verify.sh 6
```

---

## Victory!

After completing Level 6, you'll see:
- ASCII art "THREAT NEUTRALIZED"
- Stats panel (money saved, response time, records protected)
- Your grade (Senior SRE / Junior SRE / FIRED)
- "PROMOTED TO SENIOR SRE" banner
- The bankrupt counter stops

---

## Game Controller (`./game.sh`)

| Command | What it does |
|---------|-------------|
| `./game.sh start` | Start the game (same as `./start_game.sh`) |
| `./game.sh stop` | Kill the bankrupt counter, clean up temp files |
| `./game.sh reset` | Stop everything, re-run setup, start fresh |
| `./game.sh status` | Show which levels are complete |
| `./game.sh help` | Show available commands |

---

## Reset & Play Again

```bash
./game.sh stop          # Kill the counter
python3 setup.py        # Re-provision hacked resources
./start_game.sh         # Start fresh
```

---

## Quick AWS Cheat Sheet

| Service | What It Is | Key Commands |
|---------|-----------|--------------|
| **EC2** | Virtual servers | `describe-instances`, `terminate-instances` |
| **S3** | File storage buckets | `get-bucket-acl`, `put-bucket-acl` |
| **IAM** | Permissions & policies | (edit JSON files locally) |
| **Security Groups** | Firewall rules | `describe-security-groups`, `revoke-security-group-ingress` |
| **Lambda** | Serverless functions | `list-functions`, `delete-function` |
| **SSM** | Config & secrets store | `describe-parameters`, `get-parameter`, `delete-parameter` |

### Command Pattern
Every AWS CLI command follows this structure:
```
aws --endpoint-url=http://localhost:4566 <service> <action> [--flags]
```

Examples:
```bash
aws --endpoint-url=http://localhost:4566 ec2 describe-instances
aws --endpoint-url=http://localhost:4566 s3api put-bucket-acl --bucket NAME --acl private
aws --endpoint-url=http://localhost:4566 lambda list-functions
aws --endpoint-url=http://localhost:4566 ssm describe-parameters
```

**Remember:** `--endpoint-url=http://localhost:4566` is ALWAYS required. It routes commands to the local fake AWS instead of the real thing.

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `command not found: aws` | Install AWS CLI: `curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip && cd /tmp && unzip -qo awscliv2.zip && sudo ./aws/install` |
| `Could not connect to the endpoint URL` | LocalStack isn't running. Run: `sudo docker compose up -d` |
| `NoRegion` error | Run `aws configure` and set region to `us-east-1` |
| verify.sh says "verify.py not found" | Make sure you're in `~/kiro-hack/` directory |
| Bankrupt counter not showing | Terminal might be too small. Try fullscreen. |
| Multiple instances showing | You ran setup.py multiple times. Terminate ALL running ones. |
| JSON parse error on Level 3 | Your edit broke the JSON. Make sure brackets are balanced. |
| `Service 'xxx' is not enabled` | Restart LocalStack: `sudo docker compose down && sudo docker compose up -d` |
| Security group rule already revoked | You might have already fixed it. Run `./verify.sh 4` to check. |
| `ResourceNotFoundException` on Lambda | Good — that means the function is already deleted! Run `./verify.sh 5`. |
| `ParameterNotFound` on SSM | Good — that means the parameter is already gone! Run `./verify.sh 6`. |
