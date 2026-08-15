#!/bin/bash
# ============================================================
# bankrupt_counter.sh — Fixed top-bar ticker (neovim-style)
# Uses terminal scroll regions so this bar NEVER moves.
# Row 0 = status bar (fixed). Rows 2+ = scrollable content.
# ============================================================

RED='\033[1;31m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
BLACK='\033[0;30m'
BOLD='\033[1m'
RESET='\033[0m'
BG_WHITE='\033[47m'
BG_BLUE='\033[44m'

dollars=32
cents=50
rate_cents=75
elapsed=0
pulse=0

while true; do
    # Read accelerated rate from hint system if available
    if [ -f /tmp/iam_bankrupt_rate ]; then
        rate_cents=$(cat /tmp/iam_bankrupt_rate)
    fi
    COLS=$(tput cols 2>/dev/null || echo 80)
    
    # Format values
    money=$(printf "\$%d.%02d" $dollars $cents)
    mins=$((elapsed / 60))
    secs=$((elapsed % 60))
    time_str=$(printf "%02d:%02d" $mins $secs)
    
    # Build the full status bar (pad to fill entire width)
    left_text=" [IAM IN TROUBLE]  ACTIVE INCIDENT"
    right_text="COST: ${money} lost | TIME: ${time_str} "
    
    # Calculate padding between left and right
    padding_len=$((COLS - ${#left_text} - ${#right_text}))
    if [ $padding_len -lt 1 ]; then
        padding_len=1
    fi
    padding=$(printf "%${padding_len}s" "")
    
    bar="${left_text}${padding}${right_text}"
    
    # Alternate color for urgency pulse
    if [ $((pulse % 2)) -eq 0 ]; then
        BAR_COLOR="${BG_BLUE}${WHITE}${BOLD}"
    else
        BAR_COLOR="${BG_BLUE}${YELLOW}${BOLD}"
    fi
    
    # Save cursor, go to row 0 col 0, print bar, restore cursor
    tput sc
    tput cup 0 0
    printf "${BAR_COLOR}%-${COLS}s${RESET}" "$bar"
    tput rc
    
    # Increment cost
    cents=$((cents + rate_cents))
    if [ $cents -ge 100 ]; then
        dollars=$((dollars + cents / 100))
        cents=$((cents % 100))
    fi
    
    # Random spike
    if [ $((RANDOM % 5)) -eq 0 ]; then
        spike=$((RANDOM % 5 + 1))
        dollars=$((dollars + spike))
    fi
    
    # Accelerate over time
    if [ $elapsed -gt 30 ]; then
        rate_cents=$((rate_cents + 1))
    fi
    
    pulse=$((pulse + 1))
    elapsed=$((elapsed + 2))
    sleep 2
done
