# Requirements Document

## Introduction

"IAM In Trouble" is a terminal-based AWS CLI escape room game designed for hackathon demonstration. The player assumes the role of an on-call SRE awakened at 2:00 AM to discover their AWS account has been compromised. The player must use authentic AWS CLI commands targeting a local LocalStack instance to remediate three security incidents before a live "Bankrupt Counter" drains the company's simulated bank account. The game runs entirely in a Bash terminal with no web UI, using Docker + LocalStack as the mock AWS backend and Python 3 + boto3 as the game engine.

## Glossary

- **Game_Engine**: The Python 3 + boto3 application responsible for provisioning compromised AWS resources and verifying player remediation actions
- **Terminal_UI**: The collection of Bash scripts responsible for rendering ASCII art, narrative text, and the live Bankrupt Counter using ANSI escape codes
- **Verification_Engine**: The Python module (verify.py) that evaluates whether a player has successfully completed a given level
- **Setup_Script**: The Python module (setup.py) that provisions the compromised game state in LocalStack
- **Bankrupt_Counter**: An asynchronous background Bash process that displays a continuously incrementing dollar amount using ANSI escape codes to simulate financial drain
- **LocalStack**: A Docker-based local AWS cloud emulator running on port 4566 that intercepts AWS API calls
- **Player**: The human user interacting with the terminal to remediate security incidents
- **Level**: A discrete security incident that the Player must resolve using AWS CLI commands or file editing
- **Victory_Screen**: An ASCII art display rendered upon successful completion of a Level verification

## Requirements

### Requirement 1: LocalStack Environment Provisioning

**User Story:** As a player, I want the game to set up a local mock AWS environment automatically, so that I can practice real AWS CLI commands without incurring costs or requiring an AWS account.

#### Acceptance Criteria

1. WHEN setup.py is executed, THE Setup_Script SHALL create a boto3 session configured with endpoint_url 'http://localhost:4566' and dummy credentials
2. WHEN setup.py is executed, THE Setup_Script SHALL spawn one EC2 instance of type p4d.24xlarge in LocalStack and store the resulting instance ID
3. WHEN setup.py is executed, THE Setup_Script SHALL create an S3 bucket named 'customer-passwords-do-not-share' with a public-read ACL in LocalStack
4. WHEN setup.py is executed, THE Setup_Script SHALL generate a local file named 'attacker_policy.json' containing a valid IAM policy document with an explicit "Effect": "Deny" statement targeting a payroll database resource
5. IF LocalStack is not running on port 4566, THEN THE Setup_Script SHALL print an error message indicating the Docker container is unreachable and exit with code 1

### Requirement 2: Level 1 - EC2 Crypto Miner Termination

**User Story:** As a player, I want to terminate a rogue EC2 instance using the AWS CLI, so that I can learn how to stop unauthorized compute resources.

#### Acceptance Criteria

1. WHEN the Player executes `aws ec2 terminate-instances --instance-ids <id> --endpoint-url=http://localhost:4566`, THE LocalStack SHALL transition the target EC2 instance to 'terminated' state
2. WHEN verify.py is called with argument '1', THE Verification_Engine SHALL query the EC2 instance state via boto3 describe_instances
3. WHEN the EC2 instance state equals 'terminated', THE Verification_Engine SHALL exit with code 0
4. IF the EC2 instance state does not equal 'terminated', THEN THE Verification_Engine SHALL exit with code 1

### Requirement 3: Level 2 - S3 Public Access Revocation

**User Story:** As a player, I want to revoke public read access from an S3 bucket using the AWS CLI, so that I can learn how to secure exposed storage resources.

#### Acceptance Criteria

1. WHEN verify.py is called with argument '2', THE Verification_Engine SHALL retrieve the ACL of bucket 'customer-passwords-do-not-share' via boto3 get_bucket_acl
2. WHEN the bucket ACL contains no grants with a grantee URI of 'http://acs.amazonaws.com/groups/global/AllUsers', THE Verification_Engine SHALL exit with code 0
3. IF the bucket ACL contains any grant with a grantee URI of 'http://acs.amazonaws.com/groups/global/AllUsers', THEN THE Verification_Engine SHALL exit with code 1

### Requirement 4: Level 3 - Malicious IAM Policy Removal

**User Story:** As a player, I want to manually edit a malicious IAM policy file to remove a Deny block, so that I can learn how to identify and remediate policy-based attacks.

#### Acceptance Criteria

1. WHEN verify.py is called with argument '3', THE Verification_Engine SHALL read and parse the local file 'attacker_policy.json' as JSON
2. WHEN the parsed policy document contains no Statement with "Effect" equal to "Deny", THE Verification_Engine SHALL exit with code 0
3. IF the parsed policy document contains any Statement with "Effect" equal to "Deny", THEN THE Verification_Engine SHALL exit with code 1
4. IF 'attacker_policy.json' does not exist or contains invalid JSON, THEN THE Verification_Engine SHALL print a descriptive error message and exit with code 1

### Requirement 5: Bankrupt Counter Display

**User Story:** As a player, I want to see a live-updating financial drain counter in the terminal corner, so that I feel urgency to resolve the security incidents quickly.

#### Acceptance Criteria

1. WHEN start_game.sh is executed, THE Terminal_UI SHALL spawn the Bankrupt_Counter as an asynchronous background process using the '&' operator
2. WHILE the Bankrupt_Counter is running, THE Bankrupt_Counter SHALL increment a displayed dollar amount at a regular interval of no longer than 2 seconds
3. WHILE the Bankrupt_Counter is running, THE Bankrupt_Counter SHALL render the current dollar amount at a fixed screen position using ANSI escape codes without disrupting the Player's command-line input
4. WHEN the final Level is verified successfully, THE Terminal_UI SHALL terminate the Bankrupt_Counter background process using the stored process ID

### Requirement 6: Game Introduction and Narrative

**User Story:** As a player, I want an immersive narrative introduction when starting the game, so that I feel engaged with the scenario.

#### Acceptance Criteria

1. WHEN start_game.sh is executed, THE Terminal_UI SHALL render an ASCII art PagerDuty alert graphic to standard output
2. WHEN start_game.sh is executed, THE Terminal_UI SHALL invoke briefing.sh to display the narrative backstory
3. WHEN briefing.sh is executed, THE Terminal_UI SHALL print the 2:00 AM incident narrative describing the compromised API key and the active crypto miner using colored ANSI text

### Requirement 7: Level Verification Wrapper

**User Story:** As a player, I want a simple shell command to check if I've completed a level, so that I get immediate feedback on my actions.

#### Acceptance Criteria

1. WHEN the Player executes `./verify.sh <level_number>`, THE Terminal_UI SHALL pass the level_number argument to `python3 verify.py <level_number>`
2. WHEN verify.py returns exit code 0, THE Terminal_UI SHALL render a Victory_Screen with ASCII art congratulating the Player
3. IF verify.py returns exit code 1, THEN THE Terminal_UI SHALL display a failure message indicating the level is not yet resolved
4. WHEN the Player completes Level 3 verification successfully, THE Terminal_UI SHALL display a "Promoted to Senior SRE" final victory message and terminate the Bankrupt_Counter

### Requirement 8: Game File Structure

**User Story:** As a developer, I want a clean and predictable file structure, so that both developers can work in parallel without conflicts.

#### Acceptance Criteria

1. THE Game_Engine SHALL organize all game files within a single root directory named 'iam-in-trouble'
2. THE Game_Engine SHALL consist of exactly six files: setup.py, verify.py, start_game.sh, briefing.sh, verify.sh, and attacker_policy.json (generated at runtime)
3. THE Terminal_UI SHALL ensure all Bash scripts (start_game.sh, briefing.sh, verify.sh) are executable via appropriate file permission bits

### Requirement 9: Verification Engine Input Validation

**User Story:** As a player, I want clear error messages if I use verify incorrectly, so that I understand how to use the game's commands.

#### Acceptance Criteria

1. IF verify.py is called without a level argument, THEN THE Verification_Engine SHALL print a usage message specifying valid level numbers (1, 2, 3) and exit with code 1
2. IF verify.py is called with an argument that is not '1', '2', or '3', THEN THE Verification_Engine SHALL print an error message indicating the level number is invalid and exit with code 1
