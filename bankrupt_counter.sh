#!/bin/bash
# ============================================================
# bankrupt_counter.sh — Alert-style ticker with sharp look
# Prints a styled cost alert every 5 seconds.
# ============================================================

RED='\033[1;31m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
DIM='\033[2m'
BOLD='\033[1m'
RESET='\033[0m'
BG_RED='\033[41m'

dollars=32
cents=50
rate_cents=75
elapsed=0
pulse=0

while true; do
    money=$(printf "\$%d.%02d" $dollars $cents)
    mins=$((elapsed / 60))
    secs=$((elapsed % 60))
    time_str=$(printf "%02d:%02d" $mins $secs)

    # Alternate between two styles for urgency pulse
    if [ $((pulse % 2)) -eq 0 ]; then
        echo -e "  ${BG_RED}${WHITE}${BOLD} [BILLING] Cost: ${money} lost | Elapsed: ${time_str} ${RESET}" >&2
    else
        echo -e "  ${RED}${BOLD}  >>> ALERT: ${YELLOW}${money}${RED} burned | ${time_str} elapsed <<<${RESET}" >&2
    fi

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

    # Accelerate over time
    if [ $elapsed -gt 30 ]; then
        rate_cents=$((rate_cents + 1))
    fi

    pulse=$((pulse + 1))
    elapsed=$((elapsed + 5))
    sleep 5
done
