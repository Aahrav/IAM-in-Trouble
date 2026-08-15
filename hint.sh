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
        echo -e "  ${DIM}+-- HINT (Level 1) ----------------------------------------+${RESET}"
        echo -e "  ${DIM}|${RESET}                                                         ${DIM}|${RESET}"
        echo -e "  ${DIM}|${RESET} ${WHITE}  First, find what's running. Then, stop it.${RESET}           ${DIM}|${RESET}"
        echo -e "  ${DIM}|${RESET} ${WHITE}  ec2 describe-instances shows what's alive.${RESET}           ${DIM}|${RESET}"
        echo -e "  ${DIM}|${RESET} ${WHITE}  ec2 terminate-instances puts it down.${RESET}                ${DIM}|${RESET}"
        echo -e "  ${DIM}|${RESET} ${YELLOW}  Remember: --endpoint-url=http://localhost:4566${RESET}       ${DIM}|${RESET}"
        echo -e "  ${DIM}|${RESET}                                                         ${DIM}|${RESET}"
        echo -e "  ${DIM}+-------------------------------------------------------+${RESET}"
        ;;
    2)
        echo -e "  ${DIM}+-- HINT (Level 2) ----------------------------------------+${RESET}"
        echo -e "  ${DIM}|${RESET}                                                         ${DIM}|${RESET}"
        echo -e "  ${DIM}|${RESET} ${WHITE}  The bucket ACL is set to public-read.${RESET}                ${DIM}|${RESET}"
        echo -e "  ${DIM}|${RESET} ${WHITE}  Use s3api put-bucket-acl to set it private.${RESET}          ${DIM}|${RESET}"
        echo -e "  ${DIM}|${RESET} ${WHITE}  Bucket: customer-passwords-do-not-share${RESET}              ${DIM}|${RESET}"
        echo -e "  ${DIM}|${RESET} ${YELLOW}  --acl private${RESET}                                       ${DIM}|${RESET}"
        echo -e "  ${DIM}|${RESET}                                                         ${DIM}|${RESET}"
        echo -e "  ${DIM}+-------------------------------------------------------+${RESET}"
        ;;
    3)
        echo -e "  ${DIM}+-- HINT (Level 3) ----------------------------------------+${RESET}"
        echo -e "  ${DIM}|${RESET}                                                         ${DIM}|${RESET}"
        echo -e "  ${DIM}|${RESET} ${WHITE}  Open attacker_policy.json in your editor.${RESET}            ${DIM}|${RESET}"
        echo -e "  ${DIM}|${RESET} ${WHITE}  Find the statement with \"Effect\": \"Deny\"${RESET}            ${DIM}|${RESET}"
        echo -e "  ${DIM}|${RESET} ${WHITE}  Change \"Deny\" to \"Allow\" or remove the statement.${RESET}    ${DIM}|${RESET}"
        echo -e "  ${DIM}|${RESET} ${YELLOW}  Keep the JSON valid!${RESET}                                 ${DIM}|${RESET}"
        echo -e "  ${DIM}|${RESET}                                                         ${DIM}|${RESET}"
        echo -e "  ${DIM}+-------------------------------------------------------+${RESET}"
        ;;
esac

echo ""
echo -e "  ${YELLOW}  New bankrupt rate: ${WHITE}${BOLD}${NEW_RATE} cents/tick${RESET} ${YELLOW}(was cheaper before you asked)${RESET}"
echo ""
