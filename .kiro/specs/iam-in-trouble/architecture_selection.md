# Architecture Selection: iam-in-trouble

## Recommended Architecture: Service-Oriented Split

### Rationale
Candidate A achieves the lowest cross-cutting requirement percentage (22%) and evolvability cost (1.11), meaning most requirements are fully owned by a single component. It maps 1:1 to the parallel developer workflow — one dev owns Python backend, one owns Bash UI — with the exit code as the sole interface contract. The trade-off is no centralized state store; instance IDs and bucket names are implicitly shared via LocalStack queries rather than explicit coordination.

### Components
| Component | Owned State | Responsibility |
|-----------|-------------|----------------|
| SetupService (setup.py) | ec2_instance_id, s3_bucket_name, s3_bucket_acl, attacker_policy_json, aws_credentials, endpoint_url | Provision all compromised resources in LocalStack; generate attacker_policy.json; validate LocalStack connectivity |
| VerifyService (verify.py) | level_argument, verification_result, ec2_instance_state, policy_deny_present | Accept level argument, validate input, dispatch to level-specific checker, query LocalStack/filesystem, return exit code |
| TerminalUI (*.sh scripts) | bankrupt_amount, bankrupt_pid, counter_running, ascii_art_content, narrative_text, game_phase | Render ASCII art and narrative, manage background counter lifecycle, bridge player verify commands to VerifyService via exit code |

### Information Flow
| From \ To | SetupService | VerifyService | TerminalUI |
|-----------|--------------|---------------|------------|
| SetupService | — | → (LocalStack state + filesystem) | — |
| VerifyService | — | — | ← (exit code) |
| TerminalUI | — | → (invokes with level arg) | — |

### Requirement Allocation
| Requirement | Component(s) |
|-------------|--------------|
| REQ-1 (LocalStack Provisioning) | SetupService |
| REQ-2 (Level 1 EC2) | VerifyService |
| REQ-3 (Level 2 S3) | VerifyService |
| REQ-4 (Level 3 IAM) | VerifyService |
| REQ-5 (Bankrupt Counter) | TerminalUI |
| REQ-6 (Intro & Narrative) | TerminalUI |
| REQ-7 (Verify Wrapper) | TerminalUI, VerifyService |
| REQ-8 (File Structure) | SetupService, TerminalUI |
| REQ-9 (Input Validation) | VerifyService |

### Key Design-Induced Invariants
- The only runtime interface between VerifyService and TerminalUI is the process exit code (0 or 1). No shared memory, no IPC.
- SetupService and VerifyService never execute concurrently — Setup runs once before gameplay, Verify runs on-demand during gameplay.
- The Bankrupt Counter PID is owned exclusively by TerminalUI; no other component needs to know about it.
- LocalStack acts as the implicit persistence layer — both Setup (writes) and Verify (reads) access it independently via boto3.

### Alternatives Considered
| Candidate | Strength | Weakness | Why Not Selected |
|-----------|----------|----------|-----------------|
| Level-Oriented (per-level modules) | Linear scalability for new levels; high per-level cohesion | REQ1 fragments across 4 components (33% cross-cutting); higher evolvability cost (1.67) | Over-engineers a fixed 3-level hackathon game; slows parallel dev workflow |
| Pipeline with Persistence (GameStateStore) | Single source of truth; resumable game state; testable in isolation | 55% cross-cutting requirements; adds a coordination component; overkill for 4-hour sprint | Introduces coupling magnet and complexity disproportionate to a demo-focused hackathon scope |

### Metrics Summary
| Metric | Selected (Service-Oriented) | Level-Oriented | Pipeline+Persistence |
|--------|---------------------------|----------------|---------------------|
| Cross-cutting reqs % | 22% | 33% | 55% |
| Cross-cutting invariants % | 37.5% | 37.5% | 50% |
| Flow density | 0.50 | 0.40 | 0.58 |
| God object score | 33% | 33% | 28% |
| Sync cycles | 0 | 0 | 0 |
| Max fan-in | 1 | 3 | 3 |
| Max fan-out | 1 | 3 | 2 |
| Evolvability cost | 1.11 | 1.67 | 2.0 |
