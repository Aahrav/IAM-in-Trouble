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

- [ ] 8. Implement Hint System with Cost
  - [ ] 8.1 Create `hint.sh` script with level-based hints
    - Create executable `hint.sh` that accepts a level number argument (1, 2, or 3)
    - For level 1: print a hint about using `aws ec2 terminate-instances`
    - For level 2: print a hint about using `aws s3api put-bucket-acl`
    - For level 3: print a hint about editing `attacker_policy.json` to remove Deny statements
    - If invalid or missing argument, print usage message and exit with code 1
    - _Requirements: 5.2, 5.3 (extends Bankrupt Counter behavior)_

  - [ ] 8.2 Implement Bankrupt Counter acceleration on hint usage
    - Modify `start_game.sh` Bankrupt Counter to read a rate multiplier from a shared temp file (e.g., `/tmp/iam_bankrupt_rate`)
    - Default rate: $50/sec increment; after each hint, rate increases (e.g., $50 → $200 → $500)
    - In `hint.sh`, write the new accelerated rate to the shared temp file before displaying the hint
    - The Bankrupt Counter loop should re-read the rate file each iteration to pick up changes dynamically
    - _Requirements: 5.2, 5.3_

  - [ ] 8.3 Add hint cost warning to hint output
    - Before printing the hint text, display a warning in red ANSI text: "⚠️  WARNING: Asking for a hint accelerates your bankrupt rate!"
    - After displaying the hint, print the new rate (e.g., "Bankrupt rate now: $200/sec")
    - _Requirements: 5.3_

- [ ] 9. Implement Instance ID Discovery (don't hand it to them)
  - [ ] 9.1 Remove instance ID printout from `setup.py`
    - Remove or comment out the line in `provision_ec2()` that prints the instance ID to stdout
    - Instead, print a message like: "A rogue EC2 instance has been deployed... can you find it?"
    - The instance ID should NOT be directly revealed to the player
    - _Requirements: 1.2, 2.1_

  - [ ] 9.2 Update `briefing.sh` narrative to hint at discovery
    - Add a line to the briefing narrative instructing the player to discover the rogue instance themselves
    - Include a hint like: "Use your AWS CLI skills to identify the compromised instance."
    - Do NOT include the literal `describe-instances` command — the player must figure it out
    - _Requirements: 6.3_

  - [ ] 9.3 Update `verify.sh` Level 1 instructions to remove instance ID reference
    - If `verify.sh` or `start_game.sh` currently prints the instance ID as part of level instructions, remove that reference
    - Replace with narrative text that tells the player a crypto miner is running but they need to find which instance
    - _Requirements: 7.1, 2.1_

- [ ] 10. Implement Timer-Based Scoring
  - [ ] 10.1 Add game start timestamp to `start_game.sh`
    - At game start (after briefing), capture current epoch time using `date +%s`
    - Write the start timestamp to a shared temp file (e.g., `/tmp/iam_game_start_time`)
    - _Requirements: 5.1_

  - [ ] 10.2 Implement scoring logic in `verify.sh` on final level completion
    - On Level 3 success (before or after the "Promoted to Senior SRE" message), read the start timestamp from the temp file
    - Calculate elapsed time: `current_time - start_time`
    - Display a grade based on elapsed time:
      - Under 2 minutes (120s): "🏆 Grade: Senior SRE — You crushed it!"
      - Under 5 minutes (300s): "✅ Grade: Junior SRE — Not bad, but room to improve."
      - Over 5 minutes: "🔥 Grade: FIRED — Too slow, the company went bankrupt."
    - Display the total elapsed time in a human-readable format (e.g., "Time: 3m 42s")
    - _Requirements: 7.4_

  - [ ] 10.3 Add timer display alongside Bankrupt Counter
    - Modify the Bankrupt Counter background loop to also display an elapsed time counter (e.g., "⏱ 01:23") near the bankrupt amount
    - Use ANSI cursor positioning to render the timer at a fixed position (e.g., row 2, column 70)
    - The timer reads from the start timestamp temp file to calculate elapsed seconds
    - _Requirements: 5.2, 5.3_

  - [ ]* 10.4 Write unit tests for scoring logic
    - Test that elapsed time < 120s returns "Senior SRE" grade
    - Test that elapsed time between 120s and 300s returns "Junior SRE" grade
    - Test that elapsed time > 300s returns "FIRED" grade
    - Test edge cases at exact boundaries (120s, 300s)
    - _Requirements: 7.4_

- [ ] 11. Integration checkpoint for new features
  - [ ] 11.1 Wire hint system into game flow
    - Ensure `hint.sh` is executable and accessible from the game root directory
    - Verify that using a hint correctly accelerates the Bankrupt Counter in real time
    - Add `hint.sh` to the game file listing/documentation
    - _Requirements: 8.2, 8.3_

  - [ ] 11.2 Validate instance discovery flow end-to-end
    - Confirm `setup.py` no longer leaks the instance ID
    - Verify that `aws ec2 describe-instances --endpoint-url=http://localhost:4566` returns the rogue instance
    - Ensure Level 1 verification still works correctly after the player discovers and terminates the instance
    - _Requirements: 1.2, 2.1, 2.2, 2.3_

  - [ ] 11.3 Validate timer and scoring end-to-end
    - Confirm start timestamp is written correctly at game start
    - Verify elapsed time displays correctly during gameplay
    - Confirm final grade is displayed on Level 3 completion
    - _Requirements: 5.1, 7.4_

- [ ] 12. Final checkpoint for all features
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
- Tasks 8-12 implement three high-impact upgrades: Hint System with Cost, Instance ID Discovery, and Timer-Based Scoring
- The hint system uses a shared temp file (`/tmp/iam_bankrupt_rate`) for IPC between `hint.sh` and the Bankrupt Counter
- Instance ID discovery removes the "training wheels" — players must use `aws ec2 describe-instances` to find the rogue instance
- Timer-based scoring uses a shared temp file (`/tmp/iam_game_start_time`) to track elapsed gameplay time

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
    { "id": 7, "tasks": ["6.2"] },
    { "id": 8, "tasks": ["8.1", "9.1", "10.1"] },
    { "id": 9, "tasks": ["8.2", "9.2", "9.3", "10.2"] },
    { "id": 10, "tasks": ["8.3", "10.3", "10.4"] },
    { "id": 11, "tasks": ["11.1", "11.2", "11.3"] }
  ]
}
```
