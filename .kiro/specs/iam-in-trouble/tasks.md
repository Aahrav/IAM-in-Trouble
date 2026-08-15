# Implementation Plan: IAM In Trouble

## Overview

Implement a terminal-based AWS CLI escape room game with three security incident levels. The game uses Python 3 + boto3 for the game engine (setup and verification) and Bash scripts for the terminal UI (narrative, Bankrupt Counter, verification wrapper). LocalStack provides the mock AWS backend. Implementation proceeds from project structure → game engine → terminal UI → integration wiring.

## Tasks

- [x] 1. Set up project structure and core interfaces
  - [x] 1.1 Create the `iam-in-trouble` directory and initialize project files
    - Create root directory `iam-in-trouble/`
    - Create empty Python files: `setup.py`, `verify.py`
    - Create empty Bash scripts: `start_game.sh`, `briefing.sh`, `verify.sh`
    - Set executable permission bits on all `.sh` files
    - Create `tests/` directory with `__init__.py`
    - Create `pytest.ini` with test configuration (testpaths, markers for property/unit/integration)
    - Create `requirements.txt` with `boto3` and `hypothesis` dependencies
    - _Requirements: 8.1, 8.2, 8.3_

- [x] 2. Implement SetupService (`setup.py`)
  - [x] 2.1 Implement LocalStack connectivity check and boto3 session creation
    - Write `create_boto3_session()` that returns a boto3 session configured with endpoint_url `http://localhost:4566` and dummy credentials (access key, secret key, region)
    - Write `check_localstack_connectivity(session)` that attempts an API call to LocalStack and returns `True`/`False`
    - In `main()`, check connectivity first; if unreachable, print "Error: LocalStack container is not reachable on port 4566. Is Docker running?" and `sys.exit(1)`
    - _Requirements: 1.1, 1.5_

  - [x] 2.2 Implement EC2 provisioning
    - Write `provision_ec2(session)` that creates an EC2 instance of type `p4d.24xlarge` via boto3 `run_instances`
    - Store and print the resulting instance ID for player reference
    - _Requirements: 1.2_

  - [x] 2.3 Implement S3 bucket provisioning
    - Write `provision_s3(session)` that creates an S3 bucket named `customer-passwords-do-not-share` with a `public-read` ACL
    - _Requirements: 1.3_

  - [x] 2.4 Implement attacker policy file generation
    - Write `generate_attacker_policy()` that creates `attacker_policy.json` in the current directory
    - The file must contain a valid IAM policy document with a Statement containing `"Effect": "Deny"`, `"Action": "dynamodb:*"`, and a Resource targeting `arn:aws:dynamodb:us-east-1:000000000000:table/payroll-database`
    - _Requirements: 1.4_

  - [x] 2.5 Wire setup.py main orchestration
    - In `main()`, call connectivity check, then `provision_ec2`, `provision_s3`, `generate_attacker_policy` in sequence
    - Print confirmation messages after each successful provisioning step
    - Add `if __name__ == "__main__": main()` entry point
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

- [x] 3. Implement VerifyService (`verify.py`)
  - [x] 3.1 Implement argument validation and dispatch
    - Write `validate_level_arg(args)` that checks `sys.argv` for exactly one argument that is "1", "2", or "3"
    - If no argument provided, print usage message: "Usage: python3 verify.py <level>\nValid levels: 1, 2, 3" and exit with code 1
    - If argument is not "1", "2", or "3", print "Error: Invalid level '<arg>'. Must be 1, 2, or 3." and exit with code 1
    - Create `LEVEL_HANDLERS` dispatch dict mapping `{1: verify_level_1, 2: verify_level_2, 3: verify_level_3}`
    - In `main()`, validate args, dispatch to handler, `sys.exit(0)` if handler returns `True`, else `sys.exit(1)`
    - _Requirements: 9.1, 9.2_

  - [x] 3.2 Implement Level 1 verification (EC2 termination check)
    - Write `verify_level_1(session)` that calls `describe_instances` via boto3
    - Check if the EC2 instance state equals "terminated"
    - Return `True` if terminated, `False` otherwise
    - _Requirements: 2.2, 2.3, 2.4_

  - [x] 3.3 Implement Level 2 verification (S3 ACL check)
    - Write `verify_level_2(session)` that calls `get_bucket_acl` on `customer-passwords-do-not-share`
    - Iterate over grants and check if any grantee has URI `http://acs.amazonaws.com/groups/global/AllUsers`
    - Return `True` if no AllUsers grants exist, `False` otherwise
    - _Requirements: 3.1, 3.2, 3.3_

  - [x] 3.4 Implement Level 3 verification (IAM policy check)
    - Write `verify_level_3()` that reads and parses `attacker_policy.json`
    - If file does not exist, print "Error: attacker_policy.json not found. Run setup.py first." and return `False`
    - If file contains invalid JSON, print "Error: attacker_policy.json contains invalid JSON." and return `False`
    - Check if any Statement in the document has `"Effect"` equal to `"Deny"`
    - Return `True` if no Deny statements found, `False` otherwise
    - _Requirements: 4.1, 4.2, 4.3, 4.4_

  - [x]* 3.5 Write property test for EC2 verification decision
    - **Property 1: EC2 Verification Decision**
    - Use Hypothesis `text()` strategy to generate random EC2 state strings
    - Assert that `verify_level_1` logic returns `True` iff state == "terminated", `False` otherwise
    - Mock boto3 `describe_instances` to return generated state
    - `# Feature: iam-in-trouble, Property 1: EC2 Verification Decision`
    - **Validates: Requirements 2.3, 2.4**

  - [x]* 3.6 Write property test for S3 ACL verification decision
    - **Property 2: S3 ACL Verification Decision**
    - Use Hypothesis to generate lists of ACL grant dicts with random grantee URIs
    - Assert that `verify_level_2` logic returns `True` iff no grant URI equals AllUsers URI, `False` otherwise
    - Mock boto3 `get_bucket_acl` to return generated ACL grants
    - `# Feature: iam-in-trouble, Property 2: S3 ACL Verification Decision`
    - **Validates: Requirements 3.2, 3.3**

  - [x]* 3.7 Write property test for IAM policy verification decision
    - **Property 3: IAM Policy Verification Decision**
    - Use Hypothesis to generate valid IAM policy JSON documents with random Statement lists containing random Effects
    - Assert that `verify_level_3` logic returns `True` iff no Statement has `"Effect" == "Deny"`, `False` otherwise
    - Mock file reads to return generated policy JSON
    - `# Feature: iam-in-trouble, Property 3: IAM Policy Verification Decision`
    - **Validates: Requirements 4.2, 4.3**

  - [x]* 3.8 Write property test for invalid level argument rejection
    - **Property 4: Invalid Level Argument Rejection**
    - Use Hypothesis `text()` strategy filtered to exclude "1", "2", "3"
    - Assert that `validate_level_arg` always exits with code 1 for any generated input
    - `# Feature: iam-in-trouble, Property 4: Invalid Level Argument Rejection`
    - **Validates: Requirements 9.2**

- [x] 4. Checkpoint - Ensure all Python tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 5. Implement Terminal UI (Bash scripts)
  - [ ] 5.1 Implement `briefing.sh`
    - Print the 2:00 AM incident narrative using colored ANSI escape codes
    - Describe the compromised API key scenario and active crypto miner
    - Use `echo -e` or `printf` for ANSI color rendering
    - _Requirements: 6.3_

  - [ ] 5.2 Implement `start_game.sh`
    - Render ASCII art PagerDuty alert graphic to stdout
    - Invoke `./briefing.sh` for narrative backstory
    - Spawn Bankrupt Counter as background process using `&`
    - Store the background process PID in a variable (e.g., `BANKRUPT_PID`)
    - Export or write `BANKRUPT_PID` to a temp file for `verify.sh` to read
    - _Requirements: 5.1, 6.1, 6.2_

  - [ ] 5.3 Implement Bankrupt Counter (inline in `start_game.sh`)
    - Write a bash function/loop that increments a dollar amount every ~1 second
    - Use ANSI cursor positioning (`\033[s`, `\033[u`, `\033[1;70H`) to render at fixed screen position
    - Ensure the counter does not disrupt the player's command-line input
    - _Requirements: 5.2, 5.3_

  - [ ] 5.4 Implement `verify.sh`
    - Accept level number as first argument
    - Invoke `python3 verify.py $1` and capture exit code
    - If exit code 0: render level-specific Victory_Screen with ASCII art
    - If exit code 1: display failure message indicating level not yet resolved
    - On Level 3 success: display "Promoted to Senior SRE" final victory message and `kill $BANKRUPT_PID` (read PID from temp file or environment)
    - Use `kill 2>/dev/null` to silently handle already-terminated counter
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 5.4_

  - [ ]* 5.5 Write unit tests for verify.sh behavior
    - Test that verify.sh passes argument to verify.py correctly
    - Test exit code 0 triggers victory output
    - Test exit code 1 triggers failure output
    - _Requirements: 7.1, 7.2, 7.3_

- [ ] 6. Integration and wiring
  - [ ] 6.1 Wire full game flow and validate end-to-end
    - Ensure `start_game.sh` calls `briefing.sh` and spawns counter correctly
    - Ensure `verify.sh` reads the Bankrupt Counter PID and can terminate it on Level 3 completion
    - Verify all file references are relative to the `iam-in-trouble/` root directory
    - Confirm all Python scripts use the same boto3 session configuration (endpoint_url, credentials)
    - _Requirements: 8.1, 8.2, 5.4, 7.4_

  - [ ]* 6.2 Write integration tests for full game flow
    - Test: setup.py provisions resources → AWS CLI commands remediate → verify.sh confirms each level
    - Test: Bankrupt Counter starts and stops correctly with the game lifecycle
    - _Requirements: 1.1, 2.1, 3.1, 4.1, 5.1, 5.4, 7.4_

- [ ] 7. Final checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties from the design document using Hypothesis
- Unit tests validate specific examples and edge cases
- The game uses Python 3 + boto3 for game logic and Bash for terminal rendering
- LocalStack must be running in Docker on port 4566 for setup and level 1/2 verification to work
- All file paths are relative to the `iam-in-trouble/` game root directory

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1"] },
    { "id": 1, "tasks": ["2.1", "5.1"] },
    { "id": 2, "tasks": ["2.2", "2.3", "2.4", "3.1"] },
    { "id": 3, "tasks": ["2.5", "3.2", "3.3", "3.4"] },
    { "id": 4, "tasks": ["3.5", "3.6", "3.7", "3.8"] },
    { "id": 5, "tasks": ["5.2", "5.3", "5.4"] },
    { "id": 6, "tasks": ["5.5", "6.1"] },
    { "id": 7, "tasks": ["6.2"] }
  ]
}
```
