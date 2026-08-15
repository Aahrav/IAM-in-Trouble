#!/bin/bash
# ============================================================
# briefing.sh — IAM In Trouble: Narrative
# Box width: 60 chars total. Content: 58 chars between pipes.
# Using printf with fixed-width format to guarantee alignment.
# ============================================================

RED='\033[1;31m'
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
MAGENTA='\033[1;35m'
DIM='\033[2m'
BOLD='\033[1m'
RESET='\033[0m'

W=58  # inner width between | and |

box_top()    { echo -e "  ${1}+$(printf '%0.s-' $(seq 1 $W))+" ; }
box_bottom() { echo -e "  ${1}+$(printf '%0.s-' $(seq 1 $W))+${RESET}" ; }
box_line()   {
    local color="$1"
    local text="$2"
    local visible_len=${#text}
    local pad=$((W - visible_len))
    echo -e "  ${color}|${RESET}${text}$(printf '%*s' $pad '')${color}|${RESET}"
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
box_top "$CYAN"
box_line "$CYAN" "         INCIDENT REPORT -- CLASSIFIED"
box_line "$CYAN" "         Clearance Level: ON-CALL SRE"
box_bottom "$CYAN"
echo ""
sleep 0.8

# ---- Timeline ----
echo -e "  ${RED}${BOLD}== TIMELINE OF EVENTS ==${RESET}"
echo ""
_type_color "$DIM" "  [T-6:00:00] Junior dev pushes to public GitHub repo" 0.02
sleep 0.3
_type_color "$DIM" "  [T-5:59:30] AWS Access Key exposed in plaintext" 0.02
sleep 0.3
_type_color "$YELLOW" "  [T-5:59:00] [!] Bot scrapes credentials in 30 seconds" 0.02
sleep 0.3
_type_color "$RED" "  [T-5:58:00] [!!] Unauthorized API calls from 45.33.x.x" 0.02
sleep 0.3
_type_color "$RED" "  [T-0:00:00] [!!!] YOU ARE HERE -- PagerDuty triggered" 0.02
echo ""
sleep 0.8

# ---- Attacker Actions ----
echo -e "  ${RED}${BOLD}== ATTACKER ACTIONS CONFIRMED ==${RESET}"
echo ""
sleep 0.3

# Attack 1
box_top "$WHITE$BOLD"
box_line "${WHITE}${BOLD}" " ATTACK 1: Compute Hijacking"
box_top "$WHITE$BOLD"
box_line "${WHITE}${BOLD}" "  Instance: p4d.24xlarge (8x NVIDIA A100 GPUs)"
box_line "${WHITE}${BOLD}" "  Cost:     \$32.77/hour"
box_line "${WHITE}${BOLD}" "  Purpose:  Mining Dogecoin"
box_line "${WHITE}${BOLD}" "  Status:   ACTIVE -- DRAINING FUNDS"
box_bottom "${WHITE}${BOLD}"
echo ""
sleep 0.5

# Attack 2
box_top "$WHITE$BOLD"
box_line "${WHITE}${BOLD}" " ATTACK 2: Data Exfiltration"
box_top "$WHITE$BOLD"
box_line "${WHITE}${BOLD}" "  Bucket:   customer-passwords-do-not-share"
box_line "${WHITE}${BOLD}" "  ACL:      PUBLIC-READ (world accessible)"
box_line "${WHITE}${BOLD}" "  Records:  2.3 million customer entries"
box_line "${WHITE}${BOLD}" "  Status:   EXPOSED -- DATA BREACH IN PROGRESS"
box_bottom "${WHITE}${BOLD}"
echo ""
sleep 0.5

# Attack 3
box_top "$WHITE$BOLD"
box_line "${WHITE}${BOLD}" " ATTACK 3: Privilege Escalation / Denial"
box_top "$WHITE$BOLD"
box_line "${WHITE}${BOLD}" "  File:     attacker_policy.json"
box_line "${WHITE}${BOLD}" "  Action:   DENY on payroll database"
box_line "${WHITE}${BOLD}" "  Impact:   Employees cannot get paid"
box_line "${WHITE}${BOLD}" "  Status:   ACTIVE -- PAYROLL LOCKED"
box_bottom "${WHITE}${BOLD}"
echo ""
sleep 0.5

# ---- Objectives ----
echo -e "  ${GREEN}${BOLD}== RESPONSE OBJECTIVES ==${RESET}"
echo ""
box_top "$GREEN"
box_line "$GREEN" "  [1] Terminate the crypto-miner"
box_line "$GREEN" "  [2] Revoke public S3 access"
box_line "$GREEN" "  [3] Remove attacker IAM Deny rule"
box_bottom "$GREEN"
echo ""

# ---- Footer ----
echo -e "  ${DIM}--------------------------------------------------------------${RESET}"
echo -e "  ${DIM}  The CFO is on Line 1. Legal is on Line 2. Board meets at 6 AM.${RESET}"
echo -e "  ${DIM}  You have one job: Make. This. Stop.${RESET}"
echo -e "  ${WHITE}  Use your AWS CLI skills to identify the compromised instance.${RESET}"
echo -e "  ${DIM}--------------------------------------------------------------${RESET}"
echo ""
