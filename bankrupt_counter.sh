#!/bin/bash
# ============================================================
# bankrupt_counter.sh — Alert-style ticker
# Prints a small red cost line every few seconds.
# It scrolls with the terminal like real system alerts do.
# This is intentional — it creates urgency without breaking
# any terminal functionality.
# ============================================================

RED='\033[1;31m'
YELLOW='\033[1;33m'
DIM='\033[2m'
BOLD='\033[1m'
RESET='\033[0m'

dollars=32
cents=50
rate_cents=75
elapsed=0

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

    # Print a subtle alert line
    echo -e "${RED}${BOLD}  [ALERT]${RESET}${DIM} Cost: ${RESET}${YELLOW}${money}${RESET}${DIM} lost | Elapsed: ${time_str}${RESET}" >&2

    # Increment cost
    cents=$((cents + rate_cents))
    if [ $cents -ge 100 ]; then
        dollars=$((dollars + cents / 100))
        cents=$((cents % 100))
    fi

    # Random spike
    if [ $((RANDOM % 5)) -eq 0 ]; then
        dollars=$((dollars + RANDOM % 5 + 1))
    fi

    # Accelerate
    if [ $elapsed -gt 30 ]; then
        rate_cents=$((rate_cents + 1))
    fi

    elapsed=$((elapsed + 5))
    sleep 5
done
