#!/bin/bash
# ============================================================
# hint.sh — IAM In Trouble: Hint System with Cost
# Provides progressive hints at an escalating bankrupt rate.
# ============================================================

RED='\033[1;31m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
CYAN='\033[1;36m'
DIM='\033[2m'
BOLD='\033[1m'
RESET='\033[0m'

# ---- Argument Check ----
if [ -z "$1" ] || ! [[ "$1" =~ ^[123]$ ]]; then
    echo ""
    echo -e "  ${RED}${BOLD}ERROR:${RESET} Invalid or missing level."
    echo ""
    echo -e "  ${WHITE}Usage:${RESET} ${CYAN}./hint.sh <level>${RESET}"
    echo ""
    echo -e "  ${DIM}  ./hint.sh 1  ->  Hint for EC2 termination${RESET}"
    echo -e "  ${DIM}  ./hint.sh 2  ->  Hint for S3 ACL fix${RESET}"
    echo -e "  ${DIM}  ./hint.sh 3  ->  Hint for IAM policy fix${RESET}"
    echo ""
    exit 1
fi

LEVEL=$1

# ---- Determine hint count and new rate ----
HINT_COUNT_FILE="/tmp/iam_hint_count"
if [ -f "$HINT_COUNT_FILE" ]; then
    HINT_COUNT=$(cat "$HINT_COUNT_FILE")
else
    HINT_COUNT=0
fi

HINT_COUNT=$((HINT_COUNT + 1))
echo "$HINT_COUNT" > "$HINT_COUNT_FILE"

# Set rate based on cumulative hint count
case $HINT_COUNT in
    1) NEW_RATE=200 ;;
    2) NEW_RATE=500 ;;
    *) NEW_RATE=1000 ;;
esac

# Write accelerated rate
echo "$NEW_RATE" > /tmp/iam_bankrupt_rate

# ---- Warning ----
echo ""
echo -e "  ${RED}${BOLD}WARNING: Asking for a hint accelerates your bankrupt rate!${RESET}"
echo ""

# ---- Print Hint ----
case $LEVEL in
    1)
        echo -e "  ${CYAN}+-- HINT (Level 1: The Crypto Miner) -------------------------+${RESET}"
        echo -e "  ${CYAN}|${RESET}                                                            ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${WHITE}${BOLD}  WHAT HAPPENED:${RESET}                                          ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${WHITE}  An attacker launched a GPU server (EC2 instance) on${RESET}    ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${WHITE}  your account to mine cryptocurrency. It's costing you${RESET}  ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${WHITE}  \$32.77/hour. You need to shut it down.${RESET}                ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET}                                                            ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${WHITE}${BOLD}  WHAT TO DO:${RESET}                                              ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${WHITE}  1. First you need to FIND the server. In AWS, you can${RESET}  ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${WHITE}     list all running servers with 'describe-instances'.${RESET} ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${WHITE}  2. Look for the InstanceId (starts with 'i-') in the${RESET}  ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${WHITE}     output. That's the server's unique name.${RESET}            ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${WHITE}  3. Then TERMINATE (permanently delete) it using${RESET}        ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${WHITE}     'terminate-instances' with that ID.${RESET}                 ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET}                                                            ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${YELLOW}${BOLD}  COMMAND STRUCTURE:${RESET}                                        ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${YELLOW}  aws --endpoint-url=http://localhost:4566 \\${RESET}             ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${YELLOW}      ec2 <action>${RESET}                                       ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET}                                                            ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${DIM}  Actions: describe-instances, terminate-instances${RESET}        ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${DIM}  Flag: --instance-ids <the-id-you-found>${RESET}                 ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET}                                                            ${CYAN}|${RESET}"
        echo -e "  ${CYAN}+------------------------------------------------------------+${RESET}"
        ;;
    2)
        echo -e "  ${CYAN}+-- HINT (Level 2: Public S3 Bucket) -------------------------+${RESET}"
        echo -e "  ${CYAN}|${RESET}                                                            ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${WHITE}${BOLD}  WHAT HAPPENED:${RESET}                                          ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${WHITE}  S3 is Amazon's file storage service (like Dropbox).${RESET}    ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${WHITE}  A bucket called 'customer-passwords-do-not-share'${RESET}     ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${WHITE}  has been set to 'public-read' — meaning ANYONE on${RESET}     ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${WHITE}  the internet can download the files inside it.${RESET}         ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${WHITE}  2.3 million customer records are exposed.${RESET}              ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET}                                                            ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${WHITE}${BOLD}  WHAT TO DO:${RESET}                                              ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${WHITE}  Change the bucket's ACL (Access Control List) from${RESET}    ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${WHITE}  'public-read' to 'private'. This means only the${RESET}       ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${WHITE}  account owner can access the files.${RESET}                    ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET}                                                            ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${YELLOW}${BOLD}  COMMAND STRUCTURE:${RESET}                                        ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${YELLOW}  aws --endpoint-url=http://localhost:4566 \\${RESET}             ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${YELLOW}      s3api put-bucket-acl \\${RESET}                             ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${YELLOW}      --bucket <bucket-name> \\${RESET}                           ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${YELLOW}      --acl <access-level>${RESET}                                ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET}                                                            ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${DIM}  Bucket name: customer-passwords-do-not-share${RESET}           ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${DIM}  Access levels: private, public-read, public-read-write${RESET} ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${DIM}  (You want: private)${RESET}                                    ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET}                                                            ${CYAN}|${RESET}"
        echo -e "  ${CYAN}+------------------------------------------------------------+${RESET}"
        ;;
    3)
        echo -e "  ${CYAN}+-- HINT (Level 3: Malicious IAM Policy) ---------------------+${RESET}"
        echo -e "  ${CYAN}|${RESET}                                                            ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${WHITE}${BOLD}  WHAT HAPPENED:${RESET}                                          ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${WHITE}  IAM policies are JSON files that control permissions.${RESET}  ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${WHITE}  The attacker created 'attacker_policy.json' in this${RESET}   ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${WHITE}  directory. It contains a 'Deny' rule that BLOCKS${RESET}      ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${WHITE}  access to the payroll database. Nobody can get paid.${RESET}  ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET}                                                            ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${WHITE}${BOLD}  WHAT TO DO:${RESET}                                              ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${WHITE}  1. Open the file in a text editor:${RESET}                    ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${WHITE}     nano attacker_policy.json${RESET}                          ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${WHITE}  2. Find the 'Statement' array — it contains a block${RESET}  ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${WHITE}     with '\"Effect\": \"Deny\"'. That's the bad part.${RESET}       ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${WHITE}  3. Delete everything inside the [ ] brackets so it${RESET}    ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${WHITE}     becomes: \"Statement\": []${RESET}                            ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${WHITE}  4. Save: Ctrl+O, press Enter, then Ctrl+X to exit${RESET}    ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET}                                                            ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${YELLOW}${BOLD}  IMPORTANT:${RESET}                                               ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${YELLOW}  The file must remain valid JSON after editing!${RESET}         ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET} ${YELLOW}  Make sure braces {} and brackets [] are balanced.${RESET}     ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET}                                                            ${CYAN}|${RESET}"
        echo -e "  ${CYAN}+------------------------------------------------------------+${RESET}"
        ;;
esac

echo ""
echo -e "  ${YELLOW}  New bankrupt rate: ${WHITE}${BOLD}${NEW_RATE} cents/tick${RESET} ${YELLOW}(was cheaper before you asked)${RESET}"
echo ""
