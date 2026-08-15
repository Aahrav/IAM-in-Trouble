#!/bin/bash
# ============================================================
# verify.sh — IAM In Trouble: The Verification Bridge (Enhanced)
# Animated spinners, progress tracking, and epic victory screen.
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ---- Colors & Styles ----
RED='\033[1;31m'
DARK_RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
MAGENTA='\033[1;35m'
BLUE='\033[1;34m'
DIM='\033[2m'
BOLD='\033[1m'
BLINK='\033[5m'
RESET='\033[0m'
BG_GREEN='\033[42m'
BG_RED='\033[41m'
BG_YELLOW='\033[43m'
BG_BLACK='\033[40m'

# ---- Utility Functions ----

spinner_verify() {
    local msg="$1"
    local pid="$2"
    local spin_chars='⣾⣽⣻⢿⡿⣟⣯⣷'
    
    while kill -0 "$pid" 2>/dev/null; do
        for ((i=0; i<${#spin_chars}; i++)); do
            printf "\r  ${CYAN}${spin_chars:$i:1}${RESET} ${msg}"
            sleep 0.1
        done
    done
}

progress_bar() {
    local completed="$1"
    local total=3
    local width=30
    local filled=$((completed * width / total))
    local empty=$((width - filled))
    
    printf "  ${DIM}Progress: ${RESET}${GREEN}"
    for ((i=0; i<filled; i++)); do printf "█"; done
    printf "${DIM}"
    for ((i=0; i<empty; i++)); do printf "░"; done
    printf "${RESET} ${WHITE}${completed}/${total}${RESET}\n"
}

typewriter() {
    local text="$1"
    local delay="${2:-0.02}"
    for ((i=0; i<${#text}; i++)); do
        printf "%s" "${text:$i:1}"
        sleep "$delay"
    done
    echo ""
}

# Track progress
get_completed_levels() {
    local count=0
    if [ -f /tmp/iam_level1_done ]; then count=$((count + 1)); fi
    if [ -f /tmp/iam_level2_done ]; then count=$((count + 1)); fi
    if [ -f /tmp/iam_level3_done ]; then count=$((count + 1)); fi
    echo $count
}

# ---- Argument Check ----
if [ -z "$1" ]; then
    echo ""
    echo -e "  ${RED}${BOLD}ERROR:${RESET} No level specified."
    echo ""
    echo -e "  ${WHITE}Usage:${RESET} ${CYAN}./verify.sh <level>${RESET}"
    echo ""
    echo -e "  ${DIM}┌─────────────────────────────────────────┐${RESET}"
    echo -e "  ${DIM}│${RESET}  ${WHITE}./verify.sh 1${RESET}  →  Check EC2 termination  ${DIM}│${RESET}"
    echo -e "  ${DIM}│${RESET}  ${WHITE}./verify.sh 2${RESET}  →  Check S3 bucket ACL    ${DIM}│${RESET}"
    echo -e "  ${DIM}│${RESET}  ${WHITE}./verify.sh 3${RESET}  →  Check IAM policy fix   ${DIM}│${RESET}"
    echo -e "  ${DIM}└─────────────────────────────────────────┘${RESET}"
    echo ""
    exit 1
fi

LEVEL=$1

# ---- Verify Header ----
echo ""
echo -e "  ${CYAN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${RESET}"
echo -e "  ${CYAN}┃${RESET}   ${WHITE}${BOLD}🔍 VERIFICATION ENGINE — Level ${LEVEL}${RESET}                            ${CYAN}┃${RESET}"
echo -e "  ${CYAN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}"
echo ""

# ---- Animated Verification ----
# Run verify.py in background and show spinner
python3 "${SCRIPT_DIR}/verify.py" "$LEVEL" > /tmp/iam_verify_output 2>&1 &
VERIFY_PID=$!

# Show different messages per level
case $LEVEL in
    1) VERIFY_MSG="Querying EC2 instance state from CloudTrail..." ;;
    2) VERIFY_MSG="Analyzing S3 bucket ACL grants..." ;;
    3) VERIFY_MSG="Parsing IAM policy JSON structure..." ;;
    *) VERIFY_MSG="Running verification..." ;;
esac

spinner_verify "$VERIFY_MSG" $VERIFY_PID
wait $VERIFY_PID
RESULT=$?

# Print the actual verification output
echo ""
cat /tmp/iam_verify_output
echo ""

# ---- Handle Result ----
if [ $RESULT -eq 0 ]; then
    # =============== SUCCESS ===============
    printf '\a'  # Terminal bell
    
    # Mark level as complete
    touch "/tmp/iam_level${LEVEL}_done"
    COMPLETED=$(get_completed_levels)
    
    if [ "$LEVEL" -eq 3 ]; then
        # ============ FINAL VICTORY ============
        
        # Kill the bankrupt counter
        if [ -f /tmp/iam_ticker_pid ]; then
            kill $(cat /tmp/iam_ticker_pid) 2>/dev/null
            rm -f /tmp/iam_ticker_pid
        fi
        kill $! 2>/dev/null
        
        # Clear the ticker from screen
        COLS=$(tput cols 2>/dev/null || echo 80)
        printf '\033[s'
        printf "\033[1;1f"
        printf "%${COLS}s" ""
        printf '\033[u'
        
        # Calculate elapsed time
        if [ -f /tmp/iam_start_time ]; then
            START=$(cat /tmp/iam_start_time)
            ELAPSED=$((SECONDS - START))
            MINS=$((ELAPSED / 60))
            SECS=$((ELAPSED % 60))
            TIME_STR=$(printf "%02d:%02d" $MINS $SECS)
        else
            TIME_STR="??:??"
        fi
        
        sleep 0.5
        echo ""
        
        # Victory art (line by line animation)
        echo -e "${GREEN}" 
        sleep 0.1
        echo "  ╔══════════════════════════════════════════════════════════════════╗"
        sleep 0.05
        echo "  ║                                                                  ║"
        sleep 0.05
        echo "  ║   ████████╗██╗  ██╗██████╗ ███████╗ █████╗ ████████╗            ║"
        sleep 0.05
        echo "  ║   ╚══██╔══╝██║  ██║██╔══██╗██╔════╝██╔══██╗╚══██╔══╝            ║"
        sleep 0.05
        echo "  ║      ██║   ███████║██████╔╝█████╗  ███████║   ██║               ║"
        sleep 0.05
        echo "  ║      ██║   ██╔══██║██╔══██╗██╔══╝  ██╔══██║   ██║               ║"
        sleep 0.05
        echo "  ║      ██║   ██║  ██║██║  ██║███████╗██║  ██║   ██║               ║"
        sleep 0.05
        echo "  ║      ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝   ╚═╝               ║"
        sleep 0.05
        echo "  ║                                                                  ║"
        sleep 0.05
        echo "  ║   ███╗   ██╗███████╗██╗   ██╗████████╗██████╗  █████╗ ██╗       ║"
        sleep 0.05
        echo "  ║   ████╗  ██║██╔════╝██║   ██║╚══██╔══╝██╔══██╗██╔══██╗██║       ║"
        sleep 0.05
        echo "  ║   ██╔██╗ ██║█████╗  ██║   ██║   ██║   ██████╔╝███████║██║       ║"
        sleep 0.05
        echo "  ║   ██║╚██╗██║██╔══╝  ██║   ██║   ██║   ██╔══██╗██╔══██║██║       ║"
        sleep 0.05
        echo "  ║   ██║ ╚████║███████╗╚██████╔╝   ██║   ██║  ██║██║  ██║███████╗  ║"
        sleep 0.05
        echo "  ║   ╚═╝  ╚═══╝╚══════╝ ╚═════╝    ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝  ║"
        sleep 0.05
        echo "  ║                                                                  ║"
        sleep 0.05
        echo "  ╚══════════════════════════════════════════════════════════════════╝"
        echo -e "${RESET}"
        
        sleep 0.5
        printf '\a'
        
        # Stats panel
        echo -e "  ${CYAN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${RESET}"
        echo -e "  ${CYAN}┃${RESET}                                                              ${CYAN}┃${RESET}"
        echo -e "  ${CYAN}┃${RESET}   ${GREEN}💰 ESTIMATED MONEY SAVED:${RESET}    ${WHITE}${BOLD}~\$42,100.00${RESET}                  ${CYAN}┃${RESET}"
        echo -e "  ${CYAN}┃${RESET}   ${GREEN}🛡️  THREATS NEUTRALIZED:${RESET}      ${WHITE}${BOLD}3 / 3${RESET}                        ${CYAN}┃${RESET}"
        echo -e "  ${CYAN}┃${RESET}   ${GREEN}⏱️  RESPONSE TIME:${RESET}            ${WHITE}${BOLD}${TIME_STR}${RESET}                       ${CYAN}┃${RESET}"
        echo -e "  ${CYAN}┃${RESET}   ${GREEN}📊 CUSTOMER RECORDS SAVED:${RESET}   ${WHITE}${BOLD}2,300,000${RESET}                    ${CYAN}┃${RESET}"
        echo -e "  ${CYAN}┃${RESET}                                                              ${CYAN}┃${RESET}"
        echo -e "  ${CYAN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}"
        echo ""
        
        sleep 0.3
        
        # Promotion banner
        echo -e "  ${BG_GREEN}${WHITE}${BOLD}                                                              ${RESET}"
        echo -e "  ${BG_GREEN}${WHITE}${BOLD}     🎖️  CONGRATULATIONS: PROMOTED TO SENIOR SRE 🎖️           ${RESET}"
        echo -e "  ${BG_GREEN}${WHITE}${BOLD}                                                              ${RESET}"
        echo ""
        
        printf '\a'
        sleep 0.3
        
        # Final message
        echo -e "  ${DIM}┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈${RESET}"
        echo -e "  ${WHITE}  The CFO can sleep. The customers are safe. The board is pleased.${RESET}"
        echo -e "  ${DIM}  Incident Report filed. Post-mortem scheduled for Monday.${RESET}"
        echo -e "  ${DIM}  ...and that GitHub repo? It's private now.${RESET}"
        echo -e "  ${DIM}┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈${RESET}"
        echo ""
        
        # Cleanup temp files
        rm -f /tmp/iam_level1_done /tmp/iam_level2_done /tmp/iam_level3_done
        rm -f /tmp/iam_start_time /tmp/iam_verify_output
        
    else
        # ============ LEVEL 1 or 2 SUCCESS ============
        echo -e "  ${BG_GREEN}${WHITE}${BOLD} ✅ LEVEL ${LEVEL} — THREAT NEUTRALIZED ${RESET}"
        echo ""
        
        if [ "$LEVEL" -eq 1 ]; then
            echo -e "  ${GREEN}  ✓${RESET} ${WHITE}Crypto-miner terminated. GPU instance destroyed.${RESET}"
            echo -e "  ${GREEN}  ✓${RESET} ${WHITE}Estimated savings: ${GREEN}\$32.77/hr${RESET}"
            echo ""
            echo -e "  ${YELLOW}  ➤ Next Target: Lock down the S3 bucket (Level 2)${RESET}"
        elif [ "$LEVEL" -eq 2 ]; then
            echo -e "  ${GREEN}  ✓${RESET} ${WHITE}S3 bucket ACL set to private.${RESET}"
            echo -e "  ${GREEN}  ✓${RESET} ${WHITE}2.3 million customer records secured.${RESET}"
            echo ""
            echo -e "  ${YELLOW}  ➤ Next Target: Remove the IAM Deny policy (Level 3)${RESET}"
        fi
        
        echo ""
        progress_bar $COMPLETED
        echo ""
    fi
else
    # =============== FAILURE ===============
    echo -e "  ${BG_RED}${WHITE}${BOLD} ❌ LEVEL ${LEVEL} — NOT YET RESOLVED ${RESET}"
    echo ""
    
    if [ "$LEVEL" -eq 1 ]; then
        echo -e "  ${YELLOW}  ⚡ The crypto miner is still burning money!${RESET}"
        echo ""
        echo -e "  ${DIM}  ┌─ HINT ─────────────────────────────────────────────────┐${RESET}"
        echo -e "  ${DIM}  │${RESET} ${WHITE}1. Find the instance:${RESET}                                    ${DIM}│${RESET}"
        echo -e "  ${DIM}  │${RESET}    ${CYAN}aws --endpoint-url=http://localhost:4566 \\${RESET}            ${DIM}│${RESET}"
        echo -e "  ${DIM}  │${RESET}    ${CYAN}    ec2 describe-instances${RESET}                             ${DIM}│${RESET}"
        echo -e "  ${DIM}  │${RESET}                                                           ${DIM}│${RESET}"
        echo -e "  ${DIM}  │${RESET} ${WHITE}2. Terminate it:${RESET}                                         ${DIM}│${RESET}"
        echo -e "  ${DIM}  │${RESET}    ${CYAN}aws --endpoint-url=http://localhost:4566 \\${RESET}            ${DIM}│${RESET}"
        echo -e "  ${DIM}  │${RESET}    ${CYAN}    ec2 terminate-instances --instance-ids <ID>${RESET}        ${DIM}│${RESET}"
        echo -e "  ${DIM}  └─────────────────────────────────────────────────────────┘${RESET}"
        
    elif [ "$LEVEL" -eq 2 ]; then
        echo -e "  ${YELLOW}  ⚡ Customer data is still publicly accessible!${RESET}"
        echo ""
        echo -e "  ${DIM}  ┌─ HINT ─────────────────────────────────────────────────┐${RESET}"
        echo -e "  ${DIM}  │${RESET} ${WHITE}Set the bucket ACL to private:${RESET}                           ${DIM}│${RESET}"
        echo -e "  ${DIM}  │${RESET}    ${CYAN}aws --endpoint-url=http://localhost:4566 \\${RESET}            ${DIM}│${RESET}"
        echo -e "  ${DIM}  │${RESET}    ${CYAN}    s3api put-bucket-acl \\${RESET}                            ${DIM}│${RESET}"
        echo -e "  ${DIM}  │${RESET}    ${CYAN}    --bucket customer-passwords-do-not-share \\${RESET}        ${DIM}│${RESET}"
        echo -e "  ${DIM}  │${RESET}    ${CYAN}    --acl private${RESET}                                      ${DIM}│${RESET}"
        echo -e "  ${DIM}  └─────────────────────────────────────────────────────────┘${RESET}"
        
    elif [ "$LEVEL" -eq 3 ]; then
        echo -e "  ${YELLOW}  ⚡ The attacker's Deny rule is still blocking payroll!${RESET}"
        echo ""
        echo -e "  ${DIM}  ┌─ HINT ─────────────────────────────────────────────────┐${RESET}"
        echo -e "  ${DIM}  │${RESET} ${WHITE}1. Open the policy file:${RESET}                                 ${DIM}│${RESET}"
        echo -e "  ${DIM}  │${RESET}    ${CYAN}nano attacker_policy.json${RESET}                              ${DIM}│${RESET}"
        echo -e "  ${DIM}  │${RESET}                                                           ${DIM}│${RESET}"
        echo -e "  ${DIM}  │${RESET} ${WHITE}2. Find and DELETE the entire block with:${RESET}                 ${DIM}│${RESET}"
        echo -e "  ${DIM}  │${RESET}    ${YELLOW}\"Effect\": \"Deny\"${RESET}                                        ${DIM}│${RESET}"
        echo -e "  ${DIM}  │${RESET}                                                           ${DIM}│${RESET}"
        echo -e "  ${DIM}  │${RESET} ${WHITE}3. Save the file (Ctrl+O, Enter, Ctrl+X in nano)${RESET}         ${DIM}│${RESET}"
        echo -e "  ${DIM}  │${RESET}                                                           ${DIM}│${RESET}"
        echo -e "  ${DIM}  │${RESET} ${RED}⚠️  Keep the file as valid JSON!${RESET}                          ${DIM}│${RESET}"
        echo -e "  ${DIM}  └─────────────────────────────────────────────────────────┘${RESET}"
    fi
    
    echo ""
    COMPLETED=$(get_completed_levels)
    progress_bar $COMPLETED
    echo ""
    exit 1
fi
