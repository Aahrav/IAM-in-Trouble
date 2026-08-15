#!/bin/bash
# ============================================================
# verify.sh — IAM In Trouble: Verification Bridge
# Animated spinners, progress tracking, victory screen.
# No emojis.
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
DIM='\033[2m'
BOLD='\033[1m'
RESET='\033[0m'
BG_GREEN='\033[42m'
BG_RED='\033[41m'

# ---- Utility Functions ----

spinner_verify() {
    local msg="$1"
    local pid="$2"
    local spin_chars='|/-\'
    
    while kill -0 "$pid" 2>/dev/null; do
        for ((i=0; i<${#spin_chars}; i++)); do
            printf "\r  ${CYAN}[${spin_chars:$i:1}]${RESET} ${msg}"
            sleep 0.15
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
    for ((i=0; i<filled; i++)); do printf "#"; done
    printf "${DIM}"
    for ((i=0; i<empty; i++)); do printf "-"; done
    printf "${RESET} ${WHITE}${completed}/${total}${RESET}\n"
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
    echo -e "  ${DIM}+---------------------------------------+${RESET}"
    echo -e "  ${DIM}|${RESET}  ${WHITE}./verify.sh 1${RESET}  ->  Check EC2 state    ${DIM}|${RESET}"
    echo -e "  ${DIM}|${RESET}  ${WHITE}./verify.sh 2${RESET}  ->  Check S3 ACL       ${DIM}|${RESET}"
    echo -e "  ${DIM}|${RESET}  ${WHITE}./verify.sh 3${RESET}  ->  Check IAM policy   ${DIM}|${RESET}"
    echo -e "  ${DIM}+---------------------------------------+${RESET}"
    echo ""
    exit 1
fi

LEVEL=$1

# ---- Verify Header ----
echo ""
echo -e "  ${CYAN}+==============================================================+${RESET}"
echo -e "  ${CYAN}|${RESET}   ${WHITE}${BOLD}[VERIFY] VERIFICATION ENGINE -- Level ${LEVEL}${RESET}                      ${CYAN}|${RESET}"
echo -e "  ${CYAN}+==============================================================+${RESET}"
echo ""

# ---- Animated Verification ----
python3 "${SCRIPT_DIR}/verify.py" "$LEVEL" > /tmp/iam_verify_output 2>&1 &
VERIFY_PID=$!

case $LEVEL in
    1) VERIFY_MSG="Querying EC2 instance state from CloudTrail..." ;;
    2) VERIFY_MSG="Analyzing S3 bucket ACL grants..." ;;
    3) VERIFY_MSG="Parsing IAM policy JSON structure..." ;;
    *) VERIFY_MSG="Running verification..." ;;
esac

spinner_verify "$VERIFY_MSG" $VERIFY_PID
wait $VERIFY_PID
RESULT=$?

echo ""
cat /tmp/iam_verify_output
echo ""

# ---- Handle Result ----
if [ $RESULT -eq 0 ]; then
    # =============== SUCCESS ===============
    printf '\a'
    
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
        
        # Clear the fixed status bar and reset scroll region
        COLS=$(tput cols 2>/dev/null || echo 80)
        ROWS=$(tput lines 2>/dev/null || echo 24)
        printf "\033[1;${ROWS}r"
        tput sc
        tput cup 0 0
        printf "%${COLS}s" ""
        tput rc
        
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
        
        # Victory art (line by line)
        echo -e "${GREEN}"
        sleep 0.1
        echo "  +==================================================================+"
        sleep 0.05
        echo "  |                                                                  |"
        sleep 0.05
        echo "  |  ##### #   # ####  #####  ###  #####                             |"
        sleep 0.05
        echo "  |    #   #   # #   # #     #   #   #                               |"
        sleep 0.05
        echo "  |    #   ##### ####  ####  #####   #                               |"
        sleep 0.05
        echo "  |    #   #   # #  #  #     #   #   #                               |"
        sleep 0.05
        echo "  |    #   #   # #   # ##### #   #   #                               |"
        sleep 0.05
        echo "  |                                                                  |"
        sleep 0.05
        echo "  |  #   # ##### #   # ##### ####   ###  #     ##### ##### ####      |"
        sleep 0.05
        echo "  |  ##  # #     #   #   #   #   # #   # #       #     #   #   #     |"
        sleep 0.05
        echo "  |  # # # ####  #   #   #   ####  ##### #       #    ###  #   #     |"
        sleep 0.05
        echo "  |  #  ## #     #   #   #   #  #  #   # #       #   #     #   #     |"
        sleep 0.05
        echo "  |  #   # #####  ###    #   #   # #   # ##### ##### ##### ####      |"
        sleep 0.05
        echo "  |                                                                  |"
        sleep 0.05
        echo "  +==================================================================+"
        echo -e "${RESET}"
        
        sleep 0.5
        printf '\a'
        
        # Stats panel
        echo -e "  ${CYAN}+--------------------------------------------------------------+${RESET}"
        echo -e "  ${CYAN}|${RESET}                                                              ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET}   ${GREEN}ESTIMATED MONEY SAVED:${RESET}    ${WHITE}${BOLD}~\$42,100.00${RESET}                    ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET}   ${GREEN}THREATS NEUTRALIZED:${RESET}      ${WHITE}${BOLD}3 / 3${RESET}                          ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET}   ${GREEN}RESPONSE TIME:${RESET}            ${WHITE}${BOLD}${TIME_STR}${RESET}                         ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET}   ${GREEN}CUSTOMER RECORDS SAVED:${RESET}   ${WHITE}${BOLD}2,300,000${RESET}                      ${CYAN}|${RESET}"
        echo -e "  ${CYAN}|${RESET}                                                              ${CYAN}|${RESET}"
        echo -e "  ${CYAN}+--------------------------------------------------------------+${RESET}"
        echo ""
        
        # Grade based on elapsed time
        if [ -f /tmp/iam_start_time ]; then
            if [ $ELAPSED -lt 120 ]; then
                echo -e "  ${GREEN}${BOLD}Grade: SENIOR SRE -- You crushed it!${RESET}"
            elif [ $ELAPSED -lt 300 ]; then
                echo -e "  ${YELLOW}${BOLD}Grade: JUNIOR SRE -- Not bad, room to improve.${RESET}"
            else
                echo -e "  ${RED}${BOLD}Grade: FIRED -- Too slow, the company went bankrupt.${RESET}"
            fi
            echo ""
        fi
        
        sleep 0.3
        
        # Promotion banner
        echo -e "  ${BG_GREEN}${WHITE}${BOLD}                                                              ${RESET}"
        echo -e "  ${BG_GREEN}${WHITE}${BOLD}     [*] CONGRATULATIONS: PROMOTED TO SENIOR SRE [*]           ${RESET}"
        echo -e "  ${BG_GREEN}${WHITE}${BOLD}                                                              ${RESET}"
        echo ""
        
        printf '\a'
        sleep 0.3
        
        # Final message
        echo -e "  ${DIM}--------------------------------------------------------------${RESET}"
        echo -e "  ${WHITE}  The CFO can sleep. The customers are safe. The board is pleased.${RESET}"
        echo -e "  ${DIM}  Incident Report filed. Post-mortem scheduled for Monday.${RESET}"
        echo -e "  ${DIM}  ...and that GitHub repo? It's private now.${RESET}"
        echo -e "  ${DIM}--------------------------------------------------------------${RESET}"
        echo ""
        
        # Cleanup
        rm -f /tmp/iam_level1_done /tmp/iam_level2_done /tmp/iam_level3_done
        rm -f /tmp/iam_start_time /tmp/iam_verify_output
        
    else
        # ============ LEVEL 1 or 2 SUCCESS ============
        echo -e "  ${BG_GREEN}${WHITE}${BOLD} [+] LEVEL ${LEVEL} -- THREAT NEUTRALIZED ${RESET}"
        echo ""
        
        if [ "$LEVEL" -eq 1 ]; then
            echo -e "  ${GREEN}  [+]${RESET} ${WHITE}Crypto-miner terminated. GPU instance destroyed.${RESET}"
            echo -e "  ${GREEN}  [+]${RESET} ${WHITE}Estimated savings: ${GREEN}\$32.77/hr${RESET}"
            echo ""
            echo -e "  ${YELLOW}  --> Next Target: Lock down the S3 bucket (Level 2)${RESET}"
        elif [ "$LEVEL" -eq 2 ]; then
            echo -e "  ${GREEN}  [+]${RESET} ${WHITE}S3 bucket ACL set to private.${RESET}"
            echo -e "  ${GREEN}  [+]${RESET} ${WHITE}2.3 million customer records secured.${RESET}"
            echo ""
            echo -e "  ${YELLOW}  --> Next Target: Remove the IAM Deny policy (Level 3)${RESET}"
        fi
        
        echo ""
        progress_bar $COMPLETED
        echo ""
    fi
else
    # =============== FAILURE ===============
    echo -e "  ${BG_RED}${WHITE}${BOLD} [X] LEVEL ${LEVEL} -- NOT YET RESOLVED ${RESET}"
    echo ""
    
    if [ "$LEVEL" -eq 1 ]; then
        echo -e "  ${YELLOW}  [!] The crypto miner is still burning money!${RESET}"
        echo ""
        echo -e "  ${DIM}  +-- HINT ------------------------------------------------+${RESET}"
        echo -e "  ${DIM}  |${RESET}                                                         ${DIM}|${RESET}"
        echo -e "  ${DIM}  |${RESET} ${WHITE}  EC2 = virtual servers in the cloud.${RESET}                  ${DIM}|${RESET}"
        echo -e "  ${DIM}  |${RESET} ${WHITE}  The attacker launched one to mine crypto.${RESET}            ${DIM}|${RESET}"
        echo -e "  ${DIM}  |${RESET} ${WHITE}  You need to find it and shut it down.${RESET}                ${DIM}|${RESET}"
        echo -e "  ${DIM}  |${RESET}                                                         ${DIM}|${RESET}"
        echo -e "  ${DIM}  |${RESET} ${YELLOW}  Try: ./hint.sh 1  (for detailed guidance)${RESET}           ${DIM}|${RESET}"
        echo -e "  ${DIM}  |${RESET}                                                         ${DIM}|${RESET}"
        echo -e "  ${DIM}  +-------------------------------------------------------+${RESET}"
        
    elif [ "$LEVEL" -eq 2 ]; then
        echo -e "  ${YELLOW}  [!] Customer data is still publicly accessible!${RESET}"
        echo ""
        echo -e "  ${DIM}  +-- HINT ------------------------------------------------+${RESET}"
        echo -e "  ${DIM}  |${RESET}                                                         ${DIM}|${RESET}"
        echo -e "  ${DIM}  |${RESET} ${WHITE}  S3 = cloud file storage (like a public folder).${RESET}     ${DIM}|${RESET}"
        echo -e "  ${DIM}  |${RESET} ${WHITE}  The bucket's permissions let anyone read it.${RESET}         ${DIM}|${RESET}"
        echo -e "  ${DIM}  |${RESET} ${WHITE}  You need to make it private.${RESET}                         ${DIM}|${RESET}"
        echo -e "  ${DIM}  |${RESET}                                                         ${DIM}|${RESET}"
        echo -e "  ${DIM}  |${RESET} ${YELLOW}  Try: ./hint.sh 2  (for detailed guidance)${RESET}           ${DIM}|${RESET}"
        echo -e "  ${DIM}  |${RESET}                                                         ${DIM}|${RESET}"
        echo -e "  ${DIM}  +-------------------------------------------------------+${RESET}"
        
    elif [ "$LEVEL" -eq 3 ]; then
        echo -e "  ${YELLOW}  [!] The attacker's Deny rule is still blocking payroll!${RESET}"
        echo ""
        echo -e "  ${DIM}  +-- HINT ------------------------------------------------+${RESET}"
        echo -e "  ${DIM}  |${RESET}                                                         ${DIM}|${RESET}"
        echo -e "  ${DIM}  |${RESET} ${WHITE}  IAM policies = JSON files that set permissions.${RESET}      ${DIM}|${RESET}"
        echo -e "  ${DIM}  |${RESET} ${WHITE}  A 'Deny' effect blocks access to a resource.${RESET}         ${DIM}|${RESET}"
        echo -e "  ${DIM}  |${RESET} ${WHITE}  The attacker's file is right here in this folder.${RESET}    ${DIM}|${RESET}"
        echo -e "  ${DIM}  |${RESET} ${WHITE}  Edit it to remove the block.${RESET}                         ${DIM}|${RESET}"
        echo -e "  ${DIM}  |${RESET}                                                         ${DIM}|${RESET}"
        echo -e "  ${DIM}  |${RESET} ${YELLOW}  Try: ./hint.sh 3  (for detailed guidance)${RESET}           ${DIM}|${RESET}"
        echo -e "  ${DIM}  |${RESET}                                                         ${DIM}|${RESET}"
        echo -e "  ${DIM}  +-------------------------------------------------------+${RESET}"
    fi
    
    echo ""
    COMPLETED=$(get_completed_levels)
    progress_bar $COMPLETED
    echo ""
    exit 1
fi
