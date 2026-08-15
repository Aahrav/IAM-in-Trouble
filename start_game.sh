#!/bin/bash
# ============================================================
# start_game.sh — IAM In Trouble: The Grand Opening
# Clean, simple. Timer prints alert lines every 5 seconds.
# Scrolling works. Everything works.
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
BG_RED='\033[41m'

W=58

box_top()    { echo -e "  ${1}+$(printf '%0.s-' $(seq 1 $W))+${RESET}" ; }
box_bottom() { echo -e "  ${1}+$(printf '%0.s-' $(seq 1 $W))+${RESET}" ; }
box_line()   {
    local color="$1"
    local text="$2"
    local visible_len=${#text}
    local pad=$((W - visible_len))
    if [ $pad -lt 0 ]; then pad=0; fi
    echo -e "  ${color}|${RESET}${text}$(printf '%*s' $pad '')${color}|${RESET}"
}

typewriter_color() {
    local color="$1"
    local text="$2"
    local delay="${3:-0.02}"
    printf "${color}"
    for ((i=0; i<${#text}; i++)); do
        printf "%s" "${text:$i:1}"
        sleep "$delay"
    done
    printf "${RESET}\n"
}

slow_print() {
    echo -e "$1"
    sleep "${2:-0.3}"
}

spinner() {
    local msg="$1"
    local duration="${2:-2}"
    local spin_chars='|/-\'
    local end_time=$((SECONDS + duration))
    while [ $SECONDS -lt $end_time ]; do
        for ((i=0; i<${#spin_chars}; i++)); do
            printf "\r  ${CYAN}[${spin_chars:$i:1}]${RESET} ${msg}"
            sleep 0.15
        done
    done
    printf "\r  ${GREEN}[+]${RESET} ${msg}\n"
}

pulse_text() {
    local text="$1"
    local times="${2:-3}"
    for ((t=0; t<times; t++)); do
        printf "\r${RED}${BOLD}  %s${RESET}" "$text"
        sleep 0.3
        printf "\r${DARK_RED}  %s${RESET}" "$text"
        sleep 0.3
    done
    printf "\r${RED}${BOLD}  %s${RESET}\n" "$text"
}

# ---- Clear ----
clear

# ---- Boot Sequence ----
echo ""
slow_print "${DIM}  Initializing secure terminal...${RESET}" 0.2
spinner "Loading incident response toolkit" 1
spinner "Connecting to AWS CloudTrail" 1
spinner "Decrypting alert payload" 1
echo ""
sleep 0.5
printf '\a'

# ---- PagerDuty Alert ----
echo -e "${BG_RED}${WHITE}${BOLD}"
box_top ""
box_line "" "                                                          "
box_line "" "   ######   #####   ###### ####### ######                "
box_line "" "   ##   ## ##   ## ##      ##      ##   ##               "
box_line "" "   ######  ####### ## #### #####   ######                "
box_line "" "   ##      ##   ## ##   ## ##      ##  ##                "
box_line "" "   ##      ##   ##  ###### ####### ##   ##               "
box_line "" "                                                          "
box_line "" "          ######  ##   ## ######## ##   ##               "
box_line "" "          ##   ## ##   ##    ##     ## ##                "
box_line "" "          ##   ## ##   ##    ##      ###                 "
box_line "" "          ##   ## ##   ##    ##      ##                  "
box_line "" "          ######   #####     ##      ##                  "
box_line "" "                                                          "
box_bottom ""
echo -e "${RESET}"
sleep 0.3
printf '\a'

# ---- Alert Details ----
echo ""
echo -e "  ${BG_RED}${WHITE}${BOLD} [!!!] SEVERITY P1 -- CRITICAL SECURITY BREACH [!!!] ${RESET}"
echo ""
sleep 0.5

box_top "$DIM"
box_line "$DIM" "  Timestamp:  $(date '+%Y-%m-%d') 02:00:00 UTC"
box_line "$DIM" "  Source:     AWS CloudTrail / GuardDuty"
box_line "$DIM" "  Account:    prod-main (****-****-7291)"
box_line "$DIM" "  Severity:   CRITICAL -- Unauthorized API Activity"
box_line "$DIM" "  Status:     UNRESOLVED"
box_bottom "$DIM"
echo ""
sleep 1

# ---- Briefing ----
source "${SCRIPT_DIR}/briefing.sh"
sleep 1

# ---- Start Ticker ----
echo ""
pulse_text "[WARNING] BILLING ANOMALY -- COST ACCUMULATOR STARTING..."
echo ""
sleep 0.5

# Launch ticker in background (prints alert lines every 5 sec)
bash "${SCRIPT_DIR}/bankrupt_counter.sh" &
TICKER_PID=$!
echo $TICKER_PID > /tmp/iam_ticker_pid
echo $SECONDS > /tmp/iam_start_time

sleep 1

# ---- Mission Panel ----
box_top "$GREEN"
box_line "$GREEN" " [TARGET] Secure account before bankruptcy"
box_top "$GREEN"
box_line "$GREEN" ""
box_line "$GREEN" "  [ ] Level 1: Terminate crypto-miner (p4d.24xlarge)"
box_line "$GREEN" "  [ ] Level 2: Revoke public S3 access"
box_line "$GREEN" "  [ ] Level 3: Remove attacker IAM Deny policy"
box_line "$GREEN" ""
box_top "$GREEN"
box_line "$GREEN" "  Verify:   ./verify.sh <level>"
box_line "$GREEN" "  Endpoint: --endpoint-url=http://localhost:4566"
box_bottom "$GREEN"
echo ""
echo -e "  ${RED}${BOLD}[!] The money is draining. Every second counts.${RESET}"
echo -e "  ${DIM}  Cost alerts will appear every 5 seconds as a reminder.${RESET}"
echo ""
echo -e "  ${DIM}$(printf '%0.s-' $(seq 1 $W))${RESET}"
echo ""
