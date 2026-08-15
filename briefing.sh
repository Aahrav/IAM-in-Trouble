#!/bin/bash
# ============================================================
# briefing.sh — IAM In Trouble: The Narrative Dump (Enhanced)
# Typewriter-style storytelling with dramatic pauses.
# ============================================================

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
UNDERLINE='\033[4m'
RESET='\033[0m'

# Typewriter function (local to this script in case sourced independently)
_type() {
    local text="$1"
    local delay="${2:-0.02}"
    for ((i=0; i<${#text}; i++)); do
        printf "%s" "${text:$i:1}"
        sleep "$delay"
    done
    echo ""
}

_type_color() {
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

# ---- Header ----
echo ""
echo -e "  ${CYAN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${RESET}"
echo -e "  ${CYAN}┃${RESET}         ${WHITE}${BOLD}📋 INCIDENT REPORT — CLASSIFIED 📋${RESET}                 ${CYAN}┃${RESET}"
echo -e "  ${CYAN}┃${RESET}         ${DIM}Clearance Level: ON-CALL SRE${RESET}                       ${CYAN}┃${RESET}"
echo -e "  ${CYAN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}"
echo ""
sleep 0.8

# ---- Timeline (Typewriter) ----
echo -e "  ${RED}${BOLD}━━ TIMELINE OF EVENTS ━━${RESET}"
echo ""

_type_color "$DIM" "  [T-6:00:00] Junior dev pushes commit to public GitHub repo" 0.02
sleep 0.3
_type_color "$DIM" "  [T-5:59:30] AWS Access Key exposed in plaintext" 0.02
sleep 0.3
_type_color "$YELLOW" "  [T-5:59:00] ⚠️  Bot scrapes credentials within 30 seconds" 0.02
sleep 0.3
_type_color "$RED" "  [T-5:58:00] 🚨 Unauthorized API calls begin from IP 45.33.x.x" 0.02
sleep 0.3
_type_color "$RED" "  [T-0:00:00] 🚨 YOU ARE HERE — PagerDuty alert triggered" 0.02
echo ""
sleep 0.8

# ---- Attacker Actions ----
echo -e "  ${RED}${BOLD}━━ ATTACKER ACTIONS CONFIRMED ━━${RESET}"
echo ""
sleep 0.3

# Attack 1
echo -e "  ${WHITE}${BOLD}  ┌──────────────────────────────────────────────────────┐${RESET}"
echo -e "  ${WHITE}${BOLD}  │${RESET} ${RED}ATTACK 1:${RESET} ${WHITE}Compute Hijacking${RESET}                          ${WHITE}${BOLD}│${RESET}"
echo -e "  ${WHITE}${BOLD}  ├──────────────────────────────────────────────────────┤${RESET}"
echo -e "  ${WHITE}${BOLD}  │${RESET}  Instance: ${YELLOW}p4d.24xlarge${RESET} (8x NVIDIA A100 GPUs)        ${WHITE}${BOLD}│${RESET}"
echo -e "  ${WHITE}${BOLD}  │${RESET}  Cost:     ${RED}\$32.77/hour${RESET}                               ${WHITE}${BOLD}│${RESET}"
echo -e "  ${WHITE}${BOLD}  │${RESET}  Purpose:  ${MAGENTA}Mining Dogecoin${RESET} 🐕                        ${WHITE}${BOLD}│${RESET}"
echo -e "  ${WHITE}${BOLD}  │${RESET}  Status:   ${RED}ACTIVE — DRAINING FUNDS${RESET}                   ${WHITE}${BOLD}│${RESET}"
echo -e "  ${WHITE}${BOLD}  └──────────────────────────────────────────────────────┘${RESET}"
echo ""
sleep 0.5

# Attack 2
echo -e "  ${WHITE}${BOLD}  ┌──────────────────────────────────────────────────────┐${RESET}"
echo -e "  ${WHITE}${BOLD}  │${RESET} ${RED}ATTACK 2:${RESET} ${WHITE}Data Exfiltration${RESET}                          ${WHITE}${BOLD}│${RESET}"
echo -e "  ${WHITE}${BOLD}  ├──────────────────────────────────────────────────────┤${RESET}"
echo -e "  ${WHITE}${BOLD}  │${RESET}  Bucket:   ${YELLOW}customer-passwords-do-not-share${RESET}           ${WHITE}${BOLD}│${RESET}"
echo -e "  ${WHITE}${BOLD}  │${RESET}  ACL:      ${RED}PUBLIC-READ${RESET} (world accessible)            ${WHITE}${BOLD}│${RESET}"
echo -e "  ${WHITE}${BOLD}  │${RESET}  Records:  ${RED}2.3 million customer entries${RESET}              ${WHITE}${BOLD}│${RESET}"
echo -e "  ${WHITE}${BOLD}  │${RESET}  Status:   ${RED}EXPOSED — DATA BREACH IN PROGRESS${RESET}         ${WHITE}${BOLD}│${RESET}"
echo -e "  ${WHITE}${BOLD}  └──────────────────────────────────────────────────────┘${RESET}"
echo ""
sleep 0.5

# Attack 3
echo -e "  ${WHITE}${BOLD}  ┌──────────────────────────────────────────────────────┐${RESET}"
echo -e "  ${WHITE}${BOLD}  │${RESET} ${RED}ATTACK 3:${RESET} ${WHITE}Privilege Escalation / Denial${RESET}              ${WHITE}${BOLD}│${RESET}"
echo -e "  ${WHITE}${BOLD}  ├──────────────────────────────────────────────────────┤${RESET}"
echo -e "  ${WHITE}${BOLD}  │${RESET}  File:     ${YELLOW}attacker_policy.json${RESET}                      ${WHITE}${BOLD}│${RESET}"
echo -e "  ${WHITE}${BOLD}  │${RESET}  Action:   ${RED}DENY${RESET} on payroll database                  ${WHITE}${BOLD}│${RESET}"
echo -e "  ${WHITE}${BOLD}  │${RESET}  Impact:   ${RED}Employees cannot get paid${RESET}                 ${WHITE}${BOLD}│${RESET}"
echo -e "  ${WHITE}${BOLD}  │${RESET}  Status:   ${RED}ACTIVE — PAYROLL LOCKED${RESET}                   ${WHITE}${BOLD}│${RESET}"
echo -e "  ${WHITE}${BOLD}  └──────────────────────────────────────────────────────┘${RESET}"
echo ""
sleep 0.5

# ---- Objectives ----
echo -e "  ${GREEN}${BOLD}━━ RESPONSE OBJECTIVES ━━${RESET}"
echo ""
echo -e "  ${GREEN}  ┌──────────────────────────────────────────────────────┐${RESET}"
echo -e "  ${GREEN}  │${RESET}  ${WHITE}[1]${RESET} 🖥️  Terminate the crypto-miner                   ${GREEN}│${RESET}"
echo -e "  ${GREEN}  │${RESET}  ${WHITE}[2]${RESET} 🪣 Revoke public S3 access                       ${GREEN}│${RESET}"
echo -e "  ${GREEN}  │${RESET}  ${WHITE}[3]${RESET} 🔑 Remove attacker IAM Deny rule                ${GREEN}│${RESET}"
echo -e "  ${GREEN}  └──────────────────────────────────────────────────────┘${RESET}"
echo ""

# ---- Footer ----
echo -e "  ${DIM}┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈${RESET}"
echo -e "  ${DIM}  The CFO is on Line 1. Legal is on Line 2. The board meets at 6 AM.${RESET}"
echo -e "  ${DIM}  You have one job: Make. This. Stop.${RESET}"
echo -e "  ${DIM}┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈${RESET}"
echo ""
