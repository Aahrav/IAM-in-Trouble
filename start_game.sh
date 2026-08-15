#!/bin/bash
# ============================================================
# start_game.sh — IAM In Trouble: The Grand Opening
# Uses box_ln helper for perfect alignment.
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/ui_helpers.sh"

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
echo "  ╔${BOX_BORDER}╗"
sleep 0.05
echo "  ║                                                          ║"
sleep 0.05
echo "  ║   ######   #####   ###### ####### ######                ║"
sleep 0.05
echo "  ║   ##   ## ##   ## ##      ##      ##   ##               ║"
sleep 0.05
echo "  ║   ######  ####### ## #### #####   ######                ║"
sleep 0.05
echo "  ║   ##      ##   ## ##   ## ##      ##  ##                ║"
sleep 0.05
echo "  ║   ##      ##   ##  ###### ####### ##   ##               ║"
sleep 0.05
echo "  ║                                                          ║"
sleep 0.05
echo "  ║          ######  ##   ## ######## ##   ##               ║"
sleep 0.05
echo "  ║          ##   ## ##   ##    ##     ## ##                ║"
sleep 0.05
echo "  ║          ##   ## ##   ##    ##      ###                 ║"
sleep 0.05
echo "  ║          ##   ## ##   ##    ##      ##                  ║"
sleep 0.05
echo "  ║          ######   #####     ##      ##                  ║"
sleep 0.05
echo "  ║                                                          ║"
sleep 0.05
echo "  ╚${BOX_BORDER}╝"
echo -e "${RESET}"
sleep 0.3
printf '\a'

# ---- Alert Details ----
echo ""
echo -e "  ${BG_RED}${WHITE}${BOLD} [!!!] SEVERITY P1 -- CRITICAL SECURITY BREACH [!!!] ${RESET}"
echo ""
sleep 0.5

box_top "$DIM"
box_ln "$DIM" "  Timestamp:  $(date '+%Y-%m-%d') 02:00:00 UTC"
box_ln "$DIM" "  Source:     AWS CloudTrail / GuardDuty"
box_ln "$DIM" "  Account:    prod-main (****-****-7291)"
box_ln "$DIM" "  Severity:   CRITICAL -- Unauthorized API Activity"
box_ln "$DIM" "  Status:     UNRESOLVED"
box_bot "$DIM"
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

bash "${SCRIPT_DIR}/bankrupt_counter.sh" &
TICKER_PID=$!
echo $TICKER_PID > /tmp/iam_ticker_pid
echo $SECONDS > /tmp/iam_start_time

sleep 1

# ---- Mission Panel ----
box_top "$GREEN"
box_ln "$GREEN" " [TARGET] Secure account before bankruptcy"
box_mid "$GREEN"
box_ln "$GREEN" ""
box_ln "$GREEN" "  [ ] Level 1: Terminate crypto-miner (p4d.24xlarge)"
box_ln "$GREEN" "  [ ] Level 2: Revoke public S3 access"
box_ln "$GREEN" "  [ ] Level 3: Remove attacker IAM Deny policy"
box_ln "$GREEN" ""
box_mid "$GREEN"
box_ln "$GREEN" "  Verify:   ./verify.sh <level>" "  Verify:   ${CYAN}./verify.sh <level>${RESET}"
box_ln "$GREEN" "  Endpoint: --endpoint-url=http://localhost:4566" "  Endpoint: ${CYAN}--endpoint-url=http://localhost:4566${RESET}"
box_bot "$GREEN"
echo ""
echo -e "  ${RED}${BOLD}[!] The money is draining. Every second counts.${RESET}"
echo -e "  ${DIM}  Cost alerts will flash every 5 seconds. Move fast.${RESET}"
echo ""
echo -e "  ${DIM}${BOX_BORDER}${RESET}"
echo ""
