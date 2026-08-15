# IAM In Trouble — Complete Game Guide

## What Is This Game?

You're an on-call SRE (Site Reliability Engineer) woken up at 2:00 AM. Your company's AWS account has been hacked. An attacker:
1. Launched a GPU server to mine cryptocurrency (costing $32.77/hour)
2. Made a customer database publicly readable (2.3 million records exposed)
3. Locked employees out of the payroll system

You must fix all 3 problems using real AWS CLI commands before the company goes bankrupt.

---

## Game Features

### The Bankrupt Counter
A live-updating money counter ticks at the top of your terminal showing how much the attack is costing. It starts at $32.50 and accelerates over time. Random spikes happen. After 30 seconds, the rate increases automatically.

### Hints (`./hint.sh <level>`)
If you're stuck, you can ask for help — but it costs you. Each hint accelerates the bankrupt counter:
- 1st hint: rate jumps to $2.00/tick
- 2nd hint: rate jumps to $5.00/tick
- 3rd+ hint: rate jumps to $10.00/tick

### Timer & Scoring
A timer runs from game start. When you complete all 3 levels, you get a grade:
| Time | Grade |
|------|-------|
| Under 2 minutes | Senior SRE — You crushed it! |
| Under 5 minutes | Junior SRE — Not bad, room to improve |
| Over 5 minutes | FIRED — Too slow, the company went bankrupt |

### Verification (`./verify.sh <level>`)
After you fix something, run verify to check your work. It shows:
- Green "THREAT NEUTRALIZED" if you solved it
- Red "NOT YET RESOLVED" with a short nudge if you haven't
- A progress bar showing how many levels you've cleared (0/3, 1/3, etc.)

---

## Prerequisites

### 1. Docker (for the fake AWS backend)
```bash
sudo docker compose up -d
```
Wait ~10 seconds for LocalStack to start up.

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
4. A mission panel showing your 3 objectives
5. The bankrupt counter starts ticking in the top bar

---

## Available Commands During Gameplay

| Command | What it does |
|---------|-------------|
| `./verify.sh 1` | Check if Level 1 is solved |
| `./verify.sh 2` | Check if Level 2 is solved |
| `./verify.sh 3` | Check if Level 3 is solved |
| `./hint.sh 1` | Get detailed help for Level 1 (costs you!) |
| `./hint.sh 2` | Get detailed help for Level 2 (costs you!) |
| `./hint.sh 3` | Get detailed help for Level 3 (costs you!) |
| `./game.sh status` | Check game status |
| `./game.sh stop` | Stop the game / kill the counter |

---

## Level 1: Kill the Crypto Miner (EC2)

### The Problem
An attacker launched a p4d.24xlarge GPU instance (8x NVIDIA A100 GPUs) to mine Dogecoin. It costs $32.77/hour.

### Key Concepts
- **EC2** = Elastic Compute Cloud = virtual servers in AWS
- **Instance** = a single running server
- **InstanceId** = unique identifier (starts with `i-`)
- **terminate** = permanently shut down and delete a server
- **--endpoint-url** = tells AWS CLI to talk to LocalStack instead of real AWS

### How to Solve

**Step 1: Find the running instance**
```bash
aws --endpoint-url=http://localhost:4566 ec2 describe-instances
```

This outputs a big JSON blob. Look for:
- `"InstanceId": "i-xxxxxxxxxx"` — the server's unique ID
- `"InstanceType": "p4d.24xlarge"` — confirms it's the crypto miner
- `"State": {"Name": "running"}` — confirms it's still active

**Pro tip** — filter the output:
```bash
aws --endpoint-url=http://localhost:4566 ec2 describe-instances | grep -E "InstanceId|InstanceType|\"Name\""
```

**Step 2: Terminate (kill) the instance**
```bash
aws --endpoint-url=http://localhost:4566 ec2 terminate-instances --instance-ids <INSTANCE_ID>
```
Replace `<INSTANCE_ID>` with the actual ID you found (e.g., `i-abc123def456`).

**Step 3: Verify**
```bash
./verify.sh 1
```

---

## Level 2: Lock Down the S3 Bucket

### The Problem
An S3 bucket called `customer-passwords-do-not-share` has been set to `public-read`. Anyone on the internet can download 2.3 million customer records.

### Key Concepts
- **S3** = Simple Storage Service = cloud file storage (like Dropbox/Google Drive)
- **Bucket** = a container for files (like a folder)
- **ACL** = Access Control List = who can read/write the bucket
- **public-read** = everyone on the internet can download files
- **private** = only the account owner can access files
- **s3api** = the low-level S3 commands (for ACL changes, permissions, etc.)

### How to Solve

**Step 1: (Optional) See the current permissions**
```bash
aws --endpoint-url=http://localhost:4566 s3api get-bucket-acl --bucket customer-passwords-do-not-share
```
You'll see a grant with `"URI": "http://acs.amazonaws.com/groups/global/AllUsers"` — that means the entire public internet has access.

**Step 2: Set the bucket to private**
```bash
aws --endpoint-url=http://localhost:4566 s3api put-bucket-acl --bucket customer-passwords-do-not-share --acl private
```

**Step 3: Verify**
```bash
./verify.sh 2
```

---

## Level 3: Remove the Malicious IAM Policy

### The Problem
The attacker created a file called `attacker_policy.json` with a "Deny" rule that blocks all access to the payroll database. Employees cannot get paid.

### Key Concepts
- **IAM** = Identity & Access Management = the permission system in AWS
- **Policy** = a JSON document that defines what actions are allowed or denied
- **Effect: "Deny"** = explicitly blocks access to something
- **Effect: "Allow"** = explicitly permits access to something
- **Statement** = a single permission rule inside a policy
- **JSON** = a text format for data (uses `{}` braces and `[]` brackets)

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

The bad part is `"Effect": "Deny"` — this blocks all DynamoDB actions on the payroll table.

**Step 2: Edit the file**
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

**Save in nano:**
- `Ctrl+O` (write out)
- `Enter` (confirm filename)
- `Ctrl+X` (exit)

**Alternative with vim:**
```bash
vim attacker_policy.json
```
- Press `i` to enter insert mode
- Make your changes
- Press `Esc`, then type `:wq` and press `Enter` to save and quit

**Step 3: Verify**
```bash
./verify.sh 3
```

---

## Victory!

After completing Level 3, you'll see:
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

| Command Pattern | What It Does |
|----------------|-------------|
| `aws ec2 describe-instances` | List all servers |
| `aws ec2 terminate-instances --instance-ids <ID>` | Delete a server |
| `aws s3api get-bucket-acl --bucket <name>` | Check bucket permissions |
| `aws s3api put-bucket-acl --bucket <name> --acl private` | Make bucket private |
| `aws s3 ls` | List all buckets |

**Remember:** Every command needs `--endpoint-url=http://localhost:4566` at the end (or beginning) to talk to LocalStack instead of real AWS.

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `command not found: aws` | Install AWS CLI: `curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip && cd /tmp && unzip -qo awscliv2.zip && sudo ./aws/install` |
| `Could not connect to the endpoint URL` | LocalStack isn't running. Run: `sudo docker compose up -d` |
| `NoRegion` error | Run `aws configure` and set region to `us-east-1` |
| verify.sh says "verify.py not found" | Make sure you're in `~/kiro-hack/` directory |
| Bankrupt counter not showing | Terminal might be too small. Try fullscreen. |
| Multiple instances showing | You ran setup.py multiple times. Terminate all running ones. |
| JSON parse error on Level 3 | Your edit broke the JSON. Make sure brackets `{}` and `[]` are balanced. |
