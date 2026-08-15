#!/bin/bash
# ============================================================
# game.sh — IAM In Trouble: Game Controller
# The main interface for controlling the game session.
# Usage: ./game.sh [start|stop|reset|status|help]
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ---- Colors ----
RED='\033[1;31m'
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
MAGENTA='\033[1;35m'
DIM='\033[2m'
BOLD='\033[1m'
RESET='\033[0m'
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'

ACTION="${1:-help}"

case "$ACTION" in

# ═══════════════════════════════════════════════════════
# START — Launch the full game experience
# ═══════════════════════════════════════════════════════
start)
    # Check if game is already running
    if [ -f /tmp/iam_ticker_pid ] && kill -0 $(cat /tmp/iam_ticker_pid) 2>/dev/null; then
        echo ""
        echo -e "  ${YELLOW}⚠️  Game is already running!${RESET}"
        echo -e "  ${DIM}  Use ${WHITE}./game.sh status${DIM} to check progress${RESET}"
        echo -e "  ${DIM}  Use ${WHITE}./game.sh stop${DIM} to end the session${RESET}"
        echo ""
        exit 0
    fi
    
    # Launch the game
    bash "${SCRIPT_DIR}/start_game.sh"
    ;;

# ═══════════════════════════════════════════════════════
# STOP — End the game session gracefully
# ═══════════════════════════════════════════════════════
stop)
    echo ""
    echo -e "  ${CYAN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${RESET}"
    echo -e "  ${CYAN}┃${RESET}         ${WHITE}${BOLD}🛑 ENDING INCIDENT RESPONSE SESSION${RESET}                  ${CYAN}┃${RESET}"
    echo -e "  ${CYAN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}"
    echo ""
    
    # Kill the ticker
    if [ -f /tmp/iam_ticker_pid ]; then
        PID=$(cat /tmp/iam_ticker_pid)
        if kill -0 "$PID" 2>/dev/null; then
            kill "$PID" 2>/dev/null
            echo -e "  ${GREEN}✓${RESET} Bankrupt counter stopped (PID: ${PID})"
        else
            echo -e "  ${DIM}  Ticker was not running${RESET}"
        fi
        rm -f /tmp/iam_ticker_pid
    else
        # Try to kill any stray processes
        pkill -f bankrupt_counter 2>/dev/null
        echo -e "  ${DIM}  No active ticker PID found, cleaned up strays${RESET}"
    fi
    
    # Clear the ticker line from terminal
    COLS=$(tput cols 2>/dev/null || echo 80)
    printf '\033[s'
    printf "\033[1;1f"
    printf "%${COLS}s" ""
    printf '\033[u'
    
    # Show session summary
    echo ""
    COMPLETED=0
    if [ -f /tmp/iam_level1_done ]; then COMPLETED=$((COMPLETED + 1)); fi
    if [ -f /tmp/iam_level2_done ]; then COMPLETED=$((COMPLETED + 1)); fi
    if [ -f /tmp/iam_level3_done ]; then COMPLETED=$((COMPLETED + 1)); fi
    
    echo -e "  ${WHITE}Session Summary:${RESET}"
    if [ -f /tmp/iam_level1_done ]; then
        echo -e "    ${GREEN}✅ Level 1:${RESET} Crypto miner terminated"
    else
        echo -e "    ${RED}⬜ Level 1:${RESET} Crypto miner still active"
    fi
    if [ -f /tmp/iam_level2_done ]; then
        echo -e "    ${GREEN}✅ Level 2:${RESET} S3 bucket secured"
    else
        echo -e "    ${RED}⬜ Level 2:${RESET} S3 bucket still public"
    fi
    if [ -f /tmp/iam_level3_done ]; then
        echo -e "    ${GREEN}✅ Level 3:${RESET} IAM policy cleaned"
    else
        echo -e "    ${RED}⬜ Level 3:${RESET} IAM deny rule still active"
    fi
    echo ""
    echo -e "  ${DIM}  Completed: ${COMPLETED}/3 threats neutralized${RESET}"
    echo -e "  ${DIM}  Use ${WHITE}./game.sh start${DIM} to resume a new session${RESET}"
    echo ""
    ;;

# ═══════════════════════════════════════════════════════
# RESET — Full game reset (re-provision the hacked state)
# ═══════════════════════════════════════════════════════
reset)
    echo ""
    echo -e "  ${YELLOW}${BOLD}🔄 RESETTING GAME STATE...${RESET}"
    echo ""
    
    # Stop any running ticker
    if [ -f /tmp/iam_ticker_pid ]; then
        kill $(cat /tmp/iam_ticker_pid) 2>/dev/null
        rm -f /tmp/iam_ticker_pid
    fi
    pkill -f bankrupt_counter 2>/dev/null
    
    # Clear progress
    rm -f /tmp/iam_level1_done /tmp/iam_level2_done /tmp/iam_level3_done
    rm -f /tmp/iam_start_time /tmp/iam_verify_output
    
    # Clear ticker from screen
    COLS=$(tput cols 2>/dev/null || echo 80)
    printf '\033[s'
    printf "\033[1;1f"
    printf "%${COLS}s" ""
    printf '\033[u'
    
    # Re-run setup
    echo -e "  ${DIM}  Re-provisioning attack vectors...${RESET}"
    python3 "${SCRIPT_DIR}/setup.py" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "  ${GREEN}✓${RESET} Game state reset successfully!"
    else
        echo ""
        echo -e "  ${YELLOW}⚠️${RESET}  setup.py had errors (LocalStack might not be running)"
        echo -e "  ${DIM}  Level 3 (JSON file) was still reset.${RESET}"
    fi
    
    echo -e "  ${DIM}  Run ${WHITE}./game.sh start${DIM} to play again${RESET}"
    echo ""
    ;;

# ═══════════════════════════════════════════════════════
# STATUS — Check current game state
# ═══════════════════════════════════════════════════════
status)
    echo ""
    echo -e "  ${CYAN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${RESET}"
    echo -e "  ${CYAN}┃${RESET}         ${WHITE}${BOLD}📊 GAME STATUS${RESET}                                       ${CYAN}┃${RESET}"
    echo -e "  ${CYAN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}"
    echo ""
    
    # Ticker status
    if [ -f /tmp/iam_ticker_pid ] && kill -0 $(cat /tmp/iam_ticker_pid) 2>/dev/null; then
        echo -e "  ${RED}  🔴 Ticker:${RESET}  ${RED}RUNNING${RESET} (money is draining!)"
    else
        echo -e "  ${GREEN}  🟢 Ticker:${RESET}  ${DIM}Stopped${RESET}"
    fi
    echo ""
    
    # Level progress
    echo -e "  ${WHITE}  Objectives:${RESET}"
    if [ -f /tmp/iam_level1_done ]; then
        echo -e "    ${GREEN}  ✅ Level 1:${RESET} Crypto miner — ${GREEN}NEUTRALIZED${RESET}"
    else
        echo -e "    ${RED}  ⬜ Level 1:${RESET} Crypto miner — ${RED}ACTIVE${RESET}"
    fi
    if [ -f /tmp/iam_level2_done ]; then
        echo -e "    ${GREEN}  ✅ Level 2:${RESET} S3 bucket — ${GREEN}SECURED${RESET}"
    else
        echo -e "    ${RED}  ⬜ Level 2:${RESET} S3 bucket — ${RED}EXPOSED${RESET}"
    fi
    if [ -f /tmp/iam_level3_done ]; then
        echo -e "    ${GREEN}  ✅ Level 3:${RESET} IAM policy — ${GREEN}CLEANED${RESET}"
    else
        echo -e "    ${RED}  ⬜ Level 3:${RESET} IAM policy — ${RED}COMPROMISED${RESET}"
    fi
    echo ""
    
    # Progress bar
    COMPLETED=0
    if [ -f /tmp/iam_level1_done ]; then COMPLETED=$((COMPLETED + 1)); fi
    if [ -f /tmp/iam_level2_done ]; then COMPLETED=$((COMPLETED + 1)); fi
    if [ -f /tmp/iam_level3_done ]; then COMPLETED=$((COMPLETED + 1)); fi
    
    WIDTH=30
    FILLED=$((COMPLETED * WIDTH / 3))
    EMPTY=$((WIDTH - FILLED))
    
    printf "  ${DIM}  Progress: ${RESET}${GREEN}"
    for ((i=0; i<FILLED; i++)); do printf "█"; done
    printf "${DIM}"
    for ((i=0; i<EMPTY; i++)); do printf "░"; done
    printf "${RESET} ${WHITE}${COMPLETED}/3${RESET}\n"
    echo ""
    ;;

# ═══════════════════════════════════════════════════════
# HELP — Show all available commands
# ═══════════════════════════════════════════════════════
help|*)
    echo ""
    echo -e "  ${CYAN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${RESET}"
    echo -e "  ${CYAN}┃${RESET}   ${WHITE}${BOLD}🎮 IAM IN TROUBLE — Game Controller${RESET}                       ${CYAN}┃${RESET}"
    echo -e "  ${CYAN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}"
    echo ""
    echo -e "  ${WHITE}Usage:${RESET} ${CYAN}./game.sh${RESET} ${YELLOW}<command>${RESET}"
    echo ""
    echo -e "  ${WHITE}Commands:${RESET}"
    echo ""
    echo -e "    ${GREEN}start${RESET}    Launch the game (PagerDuty alert + ticker)"
    echo -e "    ${RED}stop${RESET}     End the session & kill the money ticker"
    echo -e "    ${YELLOW}reset${RESET}    Full reset — re-provision all attack vectors"
    echo -e "    ${CYAN}status${RESET}   Check your current progress"
    echo -e "    ${DIM}help${RESET}     Show this menu"
    echo ""
    echo -e "  ${WHITE}Gameplay:${RESET}"
    echo ""
    echo -e "    ${DIM}1.${RESET} ${WHITE}./game.sh start${RESET}         — Begin the escape room"
    echo -e "    ${DIM}2.${RESET} ${WHITE}aws --endpoint-url=...${RESET}  — Fix the cloud (Levels 1 & 2)"
    echo -e "    ${DIM}3.${RESET} ${WHITE}nano attacker_policy.json${RESET} — Fix the IAM policy (Level 3)"
    echo -e "    ${DIM}4.${RESET} ${WHITE}./verify.sh <level>${RESET}     — Check your work"
    echo -e "    ${DIM}5.${RESET} ${WHITE}./game.sh stop${RESET}          — End session when done"
    echo ""
    ;;

esac
