# **👯‍♂️ IAM In Trouble: Parallel Execution Playbook**

**Objective:** Build a highly polished, interactive AWS CLI terminal game in under 4 hours by splitting the workload across two developers working in parallel.

**The Strategy:** Strict separation of concerns. Developer A handles the Python/Cloud backend. Developer B handles the Bash/Visual frontend. You will not touch each other's code until Hour 3\.

## **⏱️ Phase 0: The Pre-Sprint Sync (T-Minus 15 Minutes)**

### **What is it?**

The immediate administrative setup required before you write a single line of code.

### **How to do it:**

1. **GitHub Setup:** One of you creates a public repository named iam-in-trouble and invites the other as a collaborator. Clone it locally.  
2. **Context Sharing:** Drop the iam\_in\_trouble\_spec.md (the Master Specification) into the root folder.  
3. **Kiro Priming:** Both developers open their local Kiro agents, point it at the repository, and instruct Kiro to ingest the Master Specification so both AI agents have identical context.  
4. **Branching:** Developer A creates and switches to a backend branch. Developer B creates and switches to a ui branch.

### **Why are we doing this?**

Hackathons are lost to merge conflicts and context switching. By establishing a shared AI context and distinct Git branches immediately, you guarantee you won't overwrite each other's work.

## **👨‍💻 Phase 1A: Developer A (The Backend Architect)**

**Time Allocation:** Hours 1 & 2

**Core Tools:** Python 3, boto3, Docker (LocalStack)

### **1\. LocalStack Infrastructure**

* **What:** The mock AWS cloud running locally.  
* **How:** Run docker run \-d \-p 4566:4566 localstack/localstack. Configure your local AWS CLI with aws configure (use test for all values).  
* **Why:** We need a free, instant sandbox to receive our boto3 and AWS CLI commands so we don't accidentally spend real money during development.

### **2\. The setup.py Script**

* **What:** The script that provisions the "hacked" state of the game (the rogue EC2, the public S3, the malicious JSON).  
* **How (Kiro Prompt):** *"Kiro, write setup.py. Use boto3 pointing to endpoint\_url='http://localhost:4566'. Have it spawn a p4d.24xlarge EC2 instance, create an S3 bucket named customer-passwords-do-not-share with a public-read ACL, and dump a local attacker\_policy.json file containing an explicit Deny statement."*  
* **Why:** We need a programmatic, repeatable way to instantly "reset" the game board for the judges.

### **3\. The verify.py Script**

* **What:** The evaluation engine that checks if the player successfully fixed the cloud.  
* **How (Kiro Prompt):** *"Kiro, write verify.py. It should accept an argument (1, 2, or 3). For 1, assert the LocalStack EC2 state is 'terminated'. For 2, assert the S3 bucket ACL has no public read grants. For 3, parse the local attacker\_policy.json and ensure the Deny block is gone. Exit with code 0 on success, 1 on failure."*  
* **Why:** Python is infinitely better at parsing complex JSON payloads (like IAM policies and boto3 responses) than Bash. Returning a standard exit code (0 or 1\) allows Developer B's Bash scripts to easily read the result.

## **👨‍🎨 Phase 1B: Developer B (The Terminal Director)**

**Time Allocation:** Hours 1 & 2

**Core Tools:** Bash, ANSI Escape Codes, ASCII Art

### **1\. The Bankrupt Counter (The Live Ticker)**

* **What:** A live, ticking counter in the terminal showing fake money draining from the company account.  
* **How (Kiro Prompt):** *"Kiro, write a Bash script with an infinite while loop that increments a money variable (e.g., $32.50). Use ANSI escape codes \\033\[s to save cursor, \\033\[1;80f to move to top right, and \\033\[u to restore cursor. Ensure this script is executed with & so it runs asynchronously in the background."*  
* **Why:** This creates the psychological urgency of the game. Using background processes and ANSI codes ensures the player's standard command prompt isn't interrupted by the printing text.

### **2\. The UI Shells (start\_game.sh & briefing.sh)**

* **What:** The narrative delivery mechanisms.  
* **How (Kiro Prompt):** *"Kiro, generate briefing.sh to echo out a massive neon-red ASCII PagerDuty warning, followed by the narrative of the 2:00 AM API key leak. Then write start\_game.sh to trigger this briefing and spawn the background Bankrupt Counter."*  
* **Why:** Zero web UI bloat. We want the judges fully immersed in the raw, authentic developer experience of a terminal on fire.

### **3\. The Bash Wrapper (verify.sh)**

* **What:** The bridge between the player, the UI, and Developer A's Python engine.  
* **How (Kiro Prompt):** *"Kiro, write verify.sh that takes a level number argument. It must pass this argument to python3 verify.py. If Python returns an exit code of 0, echo a massive ASCII Victory Screen and run kill $\! to stop the background Bankrupt Counter."*  
* **Why:** The player should only ever interact with Bash scripts and the AWS CLI. This wrapper hides the Python backend execution from the user.

## **🤝 Phase 2: The "Merge & Wire" Phase**

**Time Allocation:** Hour 3

### **What is it?**

Bringing the backend branch and ui branch together into main and making them talk to each other.

### **How to do it:**

1. Both developers commit their final code and merge into the main branch. Pull main locally.  
2. Run ./start\_game.sh to spawn the timer.  
3. Run python3 setup.py to spawn the broken cloud state.  
4. Manually complete Level 1 using aws \--endpoint-url=... ec2 terminate-instances...  
5. Run ./verify.sh 1\.  
6. **Debug:** Does the Bash script correctly trigger Developer A's Python script? Does the Python script correctly read LocalStack? Does the Victory screen trigger?

### **Why are we doing this?**

Integration is where software breaks. Developer A might have named a file differently than Developer B expects. Spending a full hour on integration guarantees a stable demo.

## **🏆 Phase 3: The Demo Rehearsal**

**Time Allocation:** Hour 4

### **What is it?**

Practicing the final pitch to the judges.

### **How to do it:**

1. **Assign Roles:** One of you is the **Driver** (hands on the keyboard, typing the CLI commands). The other is the **Speaker** (delivering the pitch and explaining what the Driver is doing).  
2. **The Run-Through:**  
   * Speaker: Hooks the judges with the "2:00 AM PagerDuty" narrative.  
   * Driver: Runs ./start\_game.sh. The money ticker starts.  
   * Driver: Live-types the exact AWS CLI commands to fix the issues.  
   * Driver: Runs ./verify.sh 3\. The victory screen hits.  
3. **Timing:** Ensure you can complete the pitch and all three levels in under 3 minutes.

### **Why are we doing this?**

Judges want to see the product *working*. A flawless, high-energy live demo of real CLI commands fixing a mock AWS environment will stand out massively against teams struggling with broken PowerPoint presentations.