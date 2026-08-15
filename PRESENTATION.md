# IAM In Trouble — Presentation & Demo Guide

## Overview

**Duration:** 3-5 minutes  
**Roles:**
- **Speaker** — delivers the pitch, explains what's happening
- **Driver** — hands on keyboard, types commands live

If solo, you do both.

---

## Pre-Demo Checklist (Do This BEFORE Presenting)

```bash
# 1. Make sure Docker is running
sudo docker compose up -d

# 2. Wait 15 seconds, then verify LocalStack
aws --endpoint-url=http://localhost:4566 sts get-caller-identity

# 3. Run setup to provision the hacked environment
cd ~/kiro-hack
python3 setup.py

# 4. Clean up any old game state
rm -f /tmp/iam_level*_done /tmp/iam_start_time /tmp/iam_ticker_pid /tmp/iam_bankrupt_rate /tmp/iam_hint_count

# 5. Make terminal fullscreen
# 6. Increase font size for audience visibility
# 7. Clear terminal
clear
```

**Test run it once** to make sure everything works. Know the instance ID and security group ID ahead of time.

---

## The Pitch Script

### Opening Hook (30 seconds)

> **Speaker:** "It's 2:00 AM. Your phone goes off. PagerDuty alert — CRITICAL. Someone leaked an AWS access key to a public GitHub repo 6 hours ago. A bot scraped it within 30 seconds. Your account is compromised. A crypto miner is running. Customer data is exposed. Payroll is locked. The clock is ticking. This is **IAM In Trouble**."

### What We Built (30 seconds)

> **Speaker:** "This is a terminal-based escape room that teaches AWS security through real CLI commands. No web UI. No fake commands. Everything you type is authentic AWS CLI syntax targeting a local mock backend. Zero cost, zero risk, 100% muscle memory."

### Tech Stack (15 seconds)

> **Speaker:** "Under the hood: Docker + LocalStack as the mock AWS backend, Python + boto3 as the game engine, and Bash with ANSI escape codes for the terminal theater. The only interface between frontend and backend is a process exit code — zero or one."

---

## Live Demo Script

### Act 1: Launch the Game (30 seconds)

**Driver types:**
```bash
./start_game.sh
```

> **Speaker:** "Watch the top bar — that's real money draining. Every second counts."

*Let the PagerDuty alert render. Let the briefing scroll. The audience sees the urgency.*

---

### Act 2: Level 1 — Kill the Crypto Miner (45 seconds)

**Driver types:**
```bash
aws --endpoint-url=http://localhost:4566 ec2 describe-instances | grep -E "InstanceId|InstanceType|\"Name\""
```

> **Speaker:** "First we need to find the rogue instance. We don't know its ID — we have to discover it. There it is — a p4d.24xlarge, 8 NVIDIA A100 GPUs, mining Dogecoin on our dime."

**Driver types:**
```bash
aws --endpoint-url=http://localhost:4566 ec2 terminate-instances --instance-ids <ID>
```

> **Speaker:** "Terminated. $32.77/hour saved."

**Driver types:**
```bash
./verify.sh 1
```

*Green "THREAT NEUTRALIZED" appears. Audience sees progress bar: 1/6.*

---

### Act 3: Level 2 — Lock the S3 Bucket (30 seconds)

**Driver types:**
```bash
aws --endpoint-url=http://localhost:4566 s3api put-bucket-acl --bucket customer-passwords-do-not-share --acl private
```

> **Speaker:** "2.3 million customer records were publicly accessible. One command. Private."

**Driver types:**
```bash
./verify.sh 2
```

*Green confirmation. Progress: 2/6.*

---

### Act 4: Level 3 — Remove the Deny Policy (30 seconds)

**Driver types:**
```bash
nano attacker_policy.json
```

> **Speaker:** "The attacker injected a Deny policy blocking payroll. Employees can't get paid. We open the JSON, remove the Deny statement..."

*Driver changes `"Statement": [...]` to `"Statement": []`, saves with Ctrl+O, Enter, Ctrl+X.*

**Driver types:**
```bash
./verify.sh 3
```

*Green confirmation. Progress: 3/6.*

---

### Act 5: Level 4 — Close the Security Group (30 seconds)

**Driver types:**
```bash
aws --endpoint-url=http://localhost:4566 ec2 describe-security-groups --group-names wide-open-ssh | grep GroupId
```

> **Speaker:** "SSH is wide open to the internet. Anyone can brute-force our servers. We revoke the ingress rule."

**Driver types:**
```bash
aws --endpoint-url=http://localhost:4566 ec2 revoke-security-group-ingress --group-id <SG_ID> --protocol tcp --port 22 --cidr 0.0.0.0/0
```

**Driver types:**
```bash
./verify.sh 4
```

*Green confirmation. Progress: 4/6.*

---

### Act 6: Level 5 — Delete the Backdoor Lambda (20 seconds)

**Driver types:**
```bash
aws --endpoint-url=http://localhost:4566 lambda delete-function --function-name exfiltrate-data
```

> **Speaker:** "The attacker left a serverless backdoor to exfiltrate data on demand. Gone."

**Driver types:**
```bash
./verify.sh 5
```

*Green confirmation. Progress: 5/6.*

---

### Act 7: Level 6 — Delete the Leaked Secret (20 seconds)

**Driver types:**
```bash
aws --endpoint-url=http://localhost:4566 ssm delete-parameter --name /prod/database/master-password
```

> **Speaker:** "Our database password was stored in plaintext. Deleted. In production, you'd rotate it immediately."

**Driver types:**
```bash
./verify.sh 6
```

*FINAL VICTORY SCREEN. ASCII art. "PROMOTED TO SENIOR SRE." Bankrupt counter stops. Time displayed.*

---

### Closing (30 seconds)

> **Speaker:** "Six real AWS security incidents. Six real CLI commands. Zero dollars spent. Zero risk. This is how you build cloud security muscle memory — by doing, not reading.
>
> The game runs entirely locally with Docker and LocalStack. It teaches EC2, S3, IAM, Security Groups, Lambda, and SSM Parameter Store. The bankrupt counter creates urgency. The hint system teaches without giving answers.
>
> We built this in 4 hours. Thank you."

---

## Talking Points for Q&A

### "How does it work technically?"
- LocalStack runs in Docker, emulates AWS APIs on port 4566
- `setup.py` (Python/boto3) provisions the "hacked" state
- `verify.py` (Python/boto3) checks if the player fixed each issue
- Bash scripts handle all UI (ASCII art, ANSI colors, background counter)
- The ONLY interface between Python and Bash is the exit code (0 or 1)

### "Why not a web UI?"
- The target audience lives in the terminal
- Teaches real CLI commands they'll use in production
- No frontend framework bloat — pure developer experience
- More impressive for a demo (raw terminal > polished webapp)

### "Can you add more levels?"
- Yes! The architecture is modular. Adding a new level = one function in `setup.py` + one function in `verify.py`
- Could add: CloudTrail re-enabling, VPC flow log checks, IAM user deletion, SNS topic cleanup, etc.

### "How is it different from AWS training/labs?"
- FREE — no AWS account needed, no surprise bills
- FAST — 3-5 minutes, not hours
- FUN — gamified with urgency (money counter), scoring, ASCII art
- SAFE — impossible to break real infrastructure

### "What if someone doesn't know AWS at all?"
- The hint system teaches concepts progressively
- Each hint explains WHAT the service is, WHAT happened, and the COMMAND STRUCTURE
- They never give the exact answer — the player still constructs the command

### "What services does it cover?"
| Level | Service | Concept Taught |
|-------|---------|---------------|
| 1 | EC2 | Instance discovery & termination |
| 2 | S3 | Bucket ACL management |
| 3 | IAM | Policy document structure (JSON) |
| 4 | VPC/Security Groups | Firewall rule management |
| 5 | Lambda | Serverless function lifecycle |
| 6 | SSM | Secret/parameter management |

---

## Demo Disaster Recovery

### If LocalStack crashes:
```bash
sudo docker compose down
sudo docker rm -f localstack
sudo docker compose up -d
# Wait 15 seconds
python3 setup.py
```

### If you get "already terminated" errors:
```bash
python3 setup.py   # Creates fresh resources
```

### If the counter is frozen or missing:
```bash
./game.sh stop
./start_game.sh
```

### If you forget the instance ID mid-demo:
```bash
aws --endpoint-url=http://localhost:4566 ec2 describe-instances | grep InstanceId
```

### If you forget the security group ID:
```bash
aws --endpoint-url=http://localhost:4566 ec2 describe-security-groups --group-names wide-open-ssh | grep GroupId
```

---

## Timing Targets

| Section | Target Time | Running Total |
|---------|-------------|---------------|
| Opening hook | 0:30 | 0:30 |
| What we built + tech | 0:45 | 1:15 |
| Level 1 (EC2) | 0:45 | 2:00 |
| Level 2 (S3) | 0:30 | 2:30 |
| Level 3 (IAM) | 0:30 | 3:00 |
| Level 4 (Security Group) | 0:30 | 3:30 |
| Level 5 (Lambda) | 0:20 | 3:50 |
| Level 6 (SSM) | 0:20 | 4:10 |
| Closing | 0:30 | 4:40 |

**Total: ~4:40** (under 5 minutes)

---

## Pro Tips for the Demo

1. **Pre-type commands in a notes file** — copy-paste during demo to avoid typos
2. **Know your IDs** — run `describe-instances` and `describe-security-groups` before the demo, note the IDs
3. **Big font** — at least 18pt. The audience needs to read your terminal
4. **Dark background** — ANSI colors look best on dark terminals
5. **Fullscreen** — no distractions, maximum impact
6. **Don't rush** — let the ASCII art render, let the victory screen breathe
7. **Point at the counter** — "See that? That's money burning" — creates tension
8. **If something breaks, narrate it** — "This is what real incident response looks like — things break, you adapt"
