#!/bin/bash
# ============================================================
# start_game.sh — IAM In Trouble: The Grand Opening
# Cinematic terminal experience with typewriter effects,
# animated ASCII art, and the live bankrupt ticker.
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
BLINK='\033[5m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
RESET='\033[0m'
BG_RED='\033[41m'
BG_BLACK='\033[40m'

# ---- Utility Functions ----

typewriter() {
    local text="$1"
    local delay="${2:-0.03}"
    for ((i=0; i<${#text}; i++)); do
        printf "%s" "${text:$i:1}"
        sleep "$delay"
    done
    echo ""
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
    local spin_chars='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local end_time=$((SECONDS + duration))
    
    while [ $SECONDS -lt $end_time ]; do
        for ((i=0; i<${#spin_chars}; i++)); do
            printf "\r  ${CYAN}${spin_chars:$i:1}${RESET} ${msg}"
            sleep 0.1
        done
    done
    printf "\r  ${GREEN}✓${RESET} ${msg}\n"
}

draw_line() {
    local char="${1:-━}"
    local color="${2:-$CYAN}"
    local width="${3:-64}"
    printf "${color}"
    for ((i=0; i<width; i++)); do
        printf "%s" "$char"
    done
    printf "${RESET}\n"
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

# ---- Clear Screen ----
clear

# ---- Boot Sequence Animation ----
echo ""
slow_print "${DIM}  Initializing secure terminal...${RESET}" 0.2
spinner "Loading incident response toolkit" 1
spinner "Connecting to AWS CloudTrail" 1
spinner "Decrypting alert payload" 1
echo ""
sleep 0.5

# ---- Terminal Bell (Alert Sound) ----
printf '\a'

# ---- The PagerDuty Alert (Line by Line Animation) ----
echo -e "${BG_RED}${WHITE}${BOLD}"
sleep 0.1
slow_print "  ╔════════════════════════════════════════════════════════════════╗" 0.05
slow_print "  ║                                                                ║" 0.02
slow_print "  ║     ██████╗  █████╗  ██████╗ ███████╗██████╗                  ║" 0.03
slow_print "  ║     ██╔══██╗██╔══██╗██╔════╝ ██╔════╝██╔══██╗                 ║" 0.03
slow_print "  ║     ██████╔╝███████║██║  ███╗█████╗  ██████╔╝                 ║" 0.03
slow_print "  ║     ██╔═══╝ ██╔══██║██║   ██║██╔══╝  ██╔══██╗                 ║" 0.03
slow_print "  ║     ██║     ██║  ██║╚██████╔╝███████╗██║  ██║                 ║" 0.03
slow_print "  ║     ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝                 ║" 0.03
slow_print "  ║                                                                ║" 0.02
slow_print "  ║              ██████╗ ██╗   ██╗████████╗██╗   ██╗               ║" 0.03
slow_print "  ║              ██╔══██╗██║   ██║╚══██╔══╝╚██╗ ██╔╝               ║" 0.03
slow_print "  ║              ██║  ██║██║   ██║   ██║    ╚████╔╝                ║" 0.03
slow_print "  ║              ██████╔╝╚██████╔╝   ██║     ╚██╔╝                 ║" 0.03
slow_print "  ║              ╚═════╝  ╚═════╝    ╚═╝      ╚═╝                  ║" 0.03
slow_print "  ║                                                                ║" 0.02
slow_print "  ╠════════════════════════════════════════════════════════════════╣" 0.05
echo -e "${RESET}"

sleep 0.3
printf '\a'

# ---- Alert Details (Typewriter) ----
echo ""
echo -e "  ${BG_RED}${WHITE}${BOLD} 🚨 SEVERITY: P1 — CRITICAL SECURITY BREACH 🚨 ${RESET}"
echo ""
sleep 0.5

typewriter_color "$DIM" "  ┌─────────────────────────────────────────────────────────┐" 0.01
echo -e "  ${DIM}│${RESET}  ${YELLOW}Timestamp:${WHITE}    $(date '+%Y-%m-%d') 02:00:00 UTC              ${DIM}│${RESET}"
echo -e "  ${DIM}│${RESET}  ${YELLOW}Source:${WHITE}       AWS CloudTrail / GuardDuty              ${DIM}│${RESET}"
echo -e "  ${DIM}│${RESET}  ${YELLOW}Account:${WHITE}     prod-main (****-****-7291)               ${DIM}│${RESET}"
echo -e "  ${DIM}│${RESET}  ${YELLOW}Severity:${WHITE}     ${RED}CRITICAL${WHITE} — Unauthorized API Activity     ${DIM}│${RESET}"
echo -e "  ${DIM}│${RESET}  ${YELLOW}Status:${WHITE}       ${BLINK}${RED}UNRESOLVED${RESET}                              ${DIM}│${RESET}"
typewriter_color "$DIM" "  └─────────────────────────────────────────────────────────┘" 0.01
echo ""

sleep 1

# ---- Run Briefing ----
source "${SCRIPT_DIR}/briefing.sh"

sleep 1

# ---- Start the Bankrupt Counter ----
echo ""
pulse_text "⚠️  BILLING ANOMALY DETECTED — COST ACCUMULATOR STARTING..."
echo ""
sleep 0.5

# Launch the ticker in the background
bash "${SCRIPT_DIR}/bankrupt_counter.sh" &
TICKER_PID=$!
echo $TICKER_PID > /tmp/iam_ticker_pid

# Track game start time
echo $SECONDS > /tmp/iam_start_time

sleep 1

# ---- Mission Panel ----
echo -e "  ${GREEN}╔════════════════════════════════════════════════════════════════╗${RESET}"
echo -e "  ${GREEN}║${RESET}  ${WHITE}${BOLD}🎯 YOUR MISSION: Secure the account before bankruptcy!${RESET}       ${GREEN}║${RESET}"
echo -e "  ${GREEN}╠════════════════════════════════════════════════════════════════╣${RESET}"
echo -e "  ${GREEN}║${RESET}                                                                ${GREEN}║${RESET}"
echo -e "  ${GREEN}║${RESET}  ${WHITE}⬜ Level 1:${RESET} ${YELLOW}Terminate the crypto-miner (p4d.24xlarge)${RESET}        ${GREEN}║${RESET}"
echo -e "  ${GREEN}║${RESET}  ${WHITE}⬜ Level 2:${RESET} ${YELLOW}Revoke public S3 access${RESET}                         ${GREEN}║${RESET}"
echo -e "  ${GREEN}║${RESET}  ${WHITE}⬜ Level 3:${RESET} ${YELLOW}Remove attacker IAM Deny policy${RESET}                  ${GREEN}║${RESET}"
echo -e "  ${GREEN}║${RESET}                                                                ${GREEN}║${RESET}"
echo -e "  ${GREEN}╠════════════════════════════════════════════════════════════════╣${RESET}"
echo -e "  ${GREEN}║${RESET}  ${DIM}Verify each fix:${RESET} ${CYAN}./verify.sh <level>${RESET}                        ${GREEN}║${RESET}"
echo -e "  ${GREEN}║${RESET}  ${DIM}AWS endpoint:${RESET}   ${CYAN}--endpoint-url=http://localhost:4566${RESET}       ${GREEN}║${RESET}"
echo -e "  ${GREEN}╚════════════════════════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "  ${RED}${BOLD}⏱️  The money is draining. Every second counts.${RESET}"
echo -e "  ${DIM}  Type your AWS CLI commands below to save the company.${RESET}"
echo ""
draw_line "─" "$DIM" 64
echo ""
