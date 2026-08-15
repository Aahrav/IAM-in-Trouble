#!/bin/bash
# ============================================================
# briefing.sh — Uses box_ln for perfect alignment
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/ui_helpers.sh"

# ---- Header ----
echo ""
box_top "$CYAN"
box_ln "$CYAN" "         INCIDENT REPORT -- CLASSIFIED"
box_ln "$CYAN" "         Clearance Level: ON-CALL SRE"
box_bot "$CYAN"
echo ""
sleep 0.8

# ---- Timeline ----
echo -e "  ${RED}${BOLD}══ TIMELINE OF EVENTS ══${RESET}"
echo ""
typewriter_color "$DIM" "  [T-6:00:00] Junior dev pushes to public GitHub repo" 0.02
sleep 0.3
typewriter_color "$DIM" "  [T-5:59:30] AWS Access Key exposed in plaintext" 0.02
sleep 0.3
typewriter_color "$YELLOW" "  [T-5:59:00] [!] Bot scrapes credentials in 30 seconds" 0.02
sleep 0.3
typewriter_color "$RED" "  [T-5:58:00] [!!] Unauthorized API calls from 45.33.x.x" 0.02
sleep 0.3
typewriter_color "$RED" "  [T-0:00:00] [!!!] YOU ARE HERE -- PagerDuty triggered" 0.02
echo ""
sleep 0.8

# ---- Attacker Actions ----
echo -e "  ${RED}${BOLD}══ ATTACKER ACTIONS CONFIRMED ══${RESET}"
echo ""
sleep 0.3

# Attack 1
WB="${WHITE}${BOLD}"
box_top "$WB"
box_ln "$WB" " ATTACK 1: Compute Hijacking"
box_mid "$WB"
box_ln "$WB" "  Instance: p4d.24xlarge (8x NVIDIA A100 GPUs)" "  Instance: ${YELLOW}p4d.24xlarge${RESET} (8x NVIDIA A100 GPUs)"
box_ln "$WB" "  Cost:     \$32.77/hour" "  Cost:     ${RED}\$32.77/hour${RESET}"
box_ln "$WB" "  Purpose:  Mining Dogecoin" "  Purpose:  ${MAGENTA}Mining Dogecoin${RESET}"
box_ln "$WB" "  Status:   ACTIVE -- DRAINING FUNDS" "  Status:   ${RED}ACTIVE -- DRAINING FUNDS${RESET}"
box_bot "$WB"
echo ""
sleep 0.5

# Attack 2
box_top "$WB"
box_ln "$WB" " ATTACK 2: Data Exfiltration"
box_mid "$WB"
box_ln "$WB" "  Bucket:   customer-passwords-do-not-share" "  Bucket:   ${YELLOW}customer-passwords-do-not-share${RESET}"
box_ln "$WB" "  ACL:      PUBLIC-READ (world accessible)" "  ACL:      ${RED}PUBLIC-READ${RESET} (world accessible)"
box_ln "$WB" "  Records:  2.3 million customer entries" "  Records:  ${RED}2.3 million customer entries${RESET}"
box_ln "$WB" "  Status:   EXPOSED -- DATA BREACH IN PROGRESS" "  Status:   ${RED}EXPOSED -- DATA BREACH IN PROGRESS${RESET}"
box_bot "$WB"
echo ""
sleep 0.5

# Attack 3
box_top "$WB"
box_ln "$WB" " ATTACK 3: Privilege Escalation / Denial"
box_mid "$WB"
box_ln "$WB" "  File:     attacker_policy.json" "  File:     ${YELLOW}attacker_policy.json${RESET}"
box_ln "$WB" "  Action:   DENY on payroll database" "  Action:   ${RED}DENY${RESET} on payroll database"
box_ln "$WB" "  Impact:   Employees cannot get paid" "  Impact:   ${RED}Employees cannot get paid${RESET}"
box_ln "$WB" "  Status:   ACTIVE -- PAYROLL LOCKED" "  Status:   ${RED}ACTIVE -- PAYROLL LOCKED${RESET}"
box_bot "$WB"
echo ""
sleep 0.5

# ---- Objectives ----
echo -e "  ${GREEN}${BOLD}══ RESPONSE OBJECTIVES ══${RESET}"
echo ""
box_top "$GREEN"
box_ln "$GREEN" "  [1] Terminate the crypto-miner"
box_ln "$GREEN" "  [2] Revoke public S3 access"
box_ln "$GREEN" "  [3] Remove attacker IAM Deny rule"
box_bot "$GREEN"
echo ""

# ---- Footer ----
echo -e "  ${DIM}${BOX_BORDER}${RESET}"
echo -e "  ${DIM}The CFO is on Line 1. Legal is on Line 2.${RESET}"
echo -e "  ${DIM}Board meets at 6 AM. You have one job: Make. This. Stop.${RESET}"
echo -e "  ${DIM}${BOX_BORDER}${RESET}"
echo ""
