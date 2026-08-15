#!/bin/bash
# ============================================================
# bankrupt_counter.sh — The Live Bankrupt Ticker (Enhanced)
# Background process with pulsing colors and dynamic rate.
# Adapts to terminal width. Shows both cost and elapsed time.
# ============================================================

RED='\033[1;31m'
DARK_RED='\033[0;31m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
MAGENTA='\033[1;35m'
BLINK='\033[5m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'
BG_RED='\033[41m'

# Starting values
dollars=32
cents=50
rate_cents=75
elapsed=0
pulse=0

while true; do
    # Get terminal dimensions
    COLS=$(tput cols 2>/dev/null || echo 80)
    ROWS=$(tput rows 2>/dev/null || echo 24)
    
    # Format the money amount
    money_str=$(printf "\$%d.%02d" $dollars $cents)
    
    # Format elapsed time
    mins=$((elapsed / 60))
    secs=$((elapsed % 60))
    time_str=$(printf "%02d:%02d" $mins $secs)
    
    # Alternate colors for pulsing effect
    if [ $((pulse % 2)) -eq 0 ]; then
        MONEY_COLOR="${RED}${BOLD}"
        ICON="💸"
    else
        MONEY_COLOR="${YELLOW}${BOLD}"
        ICON="🔥"
    fi
    
    # Build the ticker line
    ticker="${ICON} ${money_str} lost │ ⏱️ ${time_str}"
    TEXT_LEN=$((${#ticker} + 4))
    
    # Calculate position (top-right corner)
    START_COL=$((COLS - TEXT_LEN - 1))
    if [ $START_COL -lt 1 ]; then
        START_COL=1
    fi
    
    # Save cursor → move to position → print → restore cursor
    printf '\033[s'
    printf "\033[1;${START_COL}f"
    printf "${BG_RED}${WHITE}${BOLD} ${ICON} ${money_str} lost │ ⏱️ ${time_str} ${RESET}"
    printf '\033[u'
    
    # Increment cost (with random spikes for panic)
    cents=$((cents + rate_cents))
    if [ $cents -ge 100 ]; then
        dollars=$((dollars + cents / 100))
        cents=$((cents % 100))
    fi
    
    # Random cost spike (20% chance) — creates panic
    if [ $((RANDOM % 5)) -eq 0 ]; then
        spike=$((RANDOM % 5 + 1))
        dollars=$((dollars + spike))
    fi
    
    # Accelerate over time (cost increases faster the longer you take)
    if [ $elapsed -gt 30 ]; then
        rate_cents=$((rate_cents + 1))
    fi
    
    # Terminal bell every 30 seconds of inactivity (urgency)
    if [ $((elapsed % 30)) -eq 0 ] && [ $elapsed -gt 0 ]; then
        printf '\a'
    fi
    
    pulse=$((pulse + 1))
    elapsed=$((elapsed + 2))
    sleep 2
done
