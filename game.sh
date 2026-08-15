#!/bin/bash
# ============================================================
# game.sh — IAM In Trouble: Game Controller
# Usage: ./game.sh [start|stop|reset|status|help]
# No emojis.
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

ACTION="${1:-help}"

case "$ACTION" in

start)
    if [ -f /tmp/iam_ticker_pid ] && kill -0 $(cat /tmp/iam_ticker_pid) 2>/dev/null; then
        echo ""
        echo -e "  ${YELLOW}[!] Game is already running!${RESET}"
        echo -e "  ${DIM}  Use ${WHITE}./game.sh status${DIM} to check progress${RESET}"
        echo -e "  ${DIM}  Use ${WHITE}./game.sh stop${DIM} to end the session${RESET}"
        echo ""
        exit 0
    fi
    
    GAME_CMD="cd '${SCRIPT_DIR}' && bash start_game.sh && exec bash"
    
    if command -v wt.exe &>/dev/null; then
        wt.exe new-tab --title "IAM IN TROUBLE" --tabColor "#ff0000" \
            wsl bash -c "cd '${SCRIPT_DIR}' && bash start_game.sh && exec bash"
    elif command -v gnome-terminal &>/dev/null; then
        gnome-terminal --title="IAM IN TROUBLE -- INCIDENT RESPONSE" \
            --geometry=120x40 \
            -- bash -c "$GAME_CMD"
    elif command -v xfce4-terminal &>/dev/null; then
        xfce4-terminal --title="IAM IN TROUBLE" \
            --geometry=120x40 \
            -e "bash -c \"$GAME_CMD\""
    elif command -v cmd.exe &>/dev/null; then
        cmd.exe /c start "IAM IN TROUBLE" wsl bash -c "cd '${SCRIPT_DIR}' && bash start_game.sh && exec bash"
    else
        echo -e "  ${DIM}  (Launching in current terminal)${RESET}"
        bash "${SCRIPT_DIR}/start_game.sh"
    fi
    
    echo ""
    echo -e "  ${GREEN}[+]${RESET} Game launched!"
    echo -e "  ${DIM}  Use ${WHITE}./game.sh stop${DIM} from any terminal to end it${RESET}"
    echo ""
    ;;

stop)
    echo ""
    echo -e "  ${CYAN}+==============================================================+${RESET}"
    echo -e "  ${CYAN}|${RESET}         ${WHITE}${BOLD}[STOP] ENDING INCIDENT RESPONSE SESSION${RESET}              ${CYAN}|${RESET}"
    echo -e "  ${CYAN}+==============================================================+${RESET}"
    echo ""
    
    if [ -f /tmp/iam_ticker_pid ]; then
        PID=$(cat /tmp/iam_ticker_pid)
        if kill -0 "$PID" 2>/dev/null; then
            kill "$PID" 2>/dev/null
            echo -e "  ${GREEN}[+]${RESET} Bankrupt counter stopped (PID: ${PID})"
        else
            echo -e "  ${DIM}  Ticker was not running${RESET}"
        fi
        rm -f /tmp/iam_ticker_pid
    else
        pkill -f bankrupt_counter 2>/dev/null
        echo -e "  ${DIM}  No active ticker PID found, cleaned up strays${RESET}"
    fi
    
    # Clear the ticker line and reset scroll region
    COLS=$(tput cols 2>/dev/null || echo 80)
    ROWS=$(tput lines 2>/dev/null || echo 24)
    printf "\033[1;${ROWS}r"
    tput sc
    tput cup 0 0
    printf "%${COLS}s" ""
    tput rc
    
    # Show session summary
    echo ""
    COMPLETED=0
    if [ -f /tmp/iam_level1_done ]; then COMPLETED=$((COMPLETED + 1)); fi
    if [ -f /tmp/iam_level2_done ]; then COMPLETED=$((COMPLETED + 1)); fi
    if [ -f /tmp/iam_level3_done ]; then COMPLETED=$((COMPLETED + 1)); fi
    
    echo -e "  ${WHITE}Session Summary:${RESET}"
    if [ -f /tmp/iam_level1_done ]; then
        echo -e "    ${GREEN}[x] Level 1:${RESET} Crypto miner terminated"
    else
        echo -e "    ${RED}[ ] Level 1:${RESET} Crypto miner still active"
    fi
    if [ -f /tmp/iam_level2_done ]; then
        echo -e "    ${GREEN}[x] Level 2:${RESET} S3 bucket secured"
    else
        echo -e "    ${RED}[ ] Level 2:${RESET} S3 bucket still public"
    fi
    if [ -f /tmp/iam_level3_done ]; then
        echo -e "    ${GREEN}[x] Level 3:${RESET} IAM policy cleaned"
    else
        echo -e "    ${RED}[ ] Level 3:${RESET} IAM deny rule still active"
    fi
    echo ""
    echo -e "  ${DIM}  Completed: ${COMPLETED}/3 threats neutralized${RESET}"
    echo -e "  ${DIM}  Use ${WHITE}./game.sh start${DIM} to start a new session${RESET}"
    echo ""
    ;;

reset)
    echo ""
    echo -e "  ${YELLOW}${BOLD}[~] RESETTING GAME STATE...${RESET}"
    echo ""
    
    if [ -f /tmp/iam_ticker_pid ]; then
        kill $(cat /tmp/iam_ticker_pid) 2>/dev/null
        rm -f /tmp/iam_ticker_pid
    fi
    pkill -f bankrupt_counter 2>/dev/null
    
    rm -f /tmp/iam_level1_done /tmp/iam_level2_done /tmp/iam_level3_done
    rm -f /tmp/iam_start_time /tmp/iam_verify_output
    
    # Clear ticker
    COLS=$(tput cols 2>/dev/null || echo 80)
    tput sc
    tput cup 0 0
    printf "%${COLS}s" ""
    tput rc
    
    echo -e "  ${DIM}  Re-provisioning attack vectors...${RESET}"
    python3 "${SCRIPT_DIR}/setup.py" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "  ${GREEN}[+]${RESET} Game state reset successfully!"
    else
        echo ""
        echo -e "  ${YELLOW}[!]${RESET} setup.py had errors (LocalStack might not be running)"
        echo -e "  ${DIM}  Level 3 (JSON file) was still reset.${RESET}"
    fi
    
    echo -e "  ${DIM}  Run ${WHITE}./game.sh start${DIM} to play again${RESET}"
    echo ""
    ;;

status)
    echo ""
    echo -e "  ${CYAN}+==============================================================+${RESET}"
    echo -e "  ${CYAN}|${RESET}         ${WHITE}${BOLD}[STATUS] GAME STATE${RESET}                                   ${CYAN}|${RESET}"
    echo -e "  ${CYAN}+==============================================================+${RESET}"
    echo ""
    
    if [ -f /tmp/iam_ticker_pid ] && kill -0 $(cat /tmp/iam_ticker_pid) 2>/dev/null; then
        echo -e "  ${RED}  [ACTIVE]${RESET} Ticker is ${RED}RUNNING${RESET} (money is draining!)"
    else
        echo -e "  ${GREEN}  [IDLE]${RESET}   Ticker is ${DIM}stopped${RESET}"
    fi
    echo ""
    
    echo -e "  ${WHITE}  Objectives:${RESET}"
    if [ -f /tmp/iam_level1_done ]; then
        echo -e "    ${GREEN}  [x] Level 1:${RESET} Crypto miner -- ${GREEN}NEUTRALIZED${RESET}"
    else
        echo -e "    ${RED}  [ ] Level 1:${RESET} Crypto miner -- ${RED}ACTIVE${RESET}"
    fi
    if [ -f /tmp/iam_level2_done ]; then
        echo -e "    ${GREEN}  [x] Level 2:${RESET} S3 bucket -- ${GREEN}SECURED${RESET}"
    else
        echo -e "    ${RED}  [ ] Level 2:${RESET} S3 bucket -- ${RED}EXPOSED${RESET}"
    fi
    if [ -f /tmp/iam_level3_done ]; then
        echo -e "    ${GREEN}  [x] Level 3:${RESET} IAM policy -- ${GREEN}CLEANED${RESET}"
    else
        echo -e "    ${RED}  [ ] Level 3:${RESET} IAM policy -- ${RED}COMPROMISED${RESET}"
    fi
    echo ""
    
    COMPLETED=0
    if [ -f /tmp/iam_level1_done ]; then COMPLETED=$((COMPLETED + 1)); fi
    if [ -f /tmp/iam_level2_done ]; then COMPLETED=$((COMPLETED + 1)); fi
    if [ -f /tmp/iam_level3_done ]; then COMPLETED=$((COMPLETED + 1)); fi
    
    WIDTH=30
    FILLED=$((COMPLETED * WIDTH / 3))
    EMPTY=$((WIDTH - FILLED))
    
    printf "  ${DIM}  Progress: ${RESET}${GREEN}"
    for ((i=0; i<FILLED; i++)); do printf "#"; done
    printf "${DIM}"
    for ((i=0; i<EMPTY; i++)); do printf "-"; done
    printf "${RESET} ${WHITE}${COMPLETED}/3${RESET}\n"
    echo ""
    ;;

help|*)
    echo ""
    echo -e "  ${CYAN}+==============================================================+${RESET}"
    echo -e "  ${CYAN}|${RESET}   ${WHITE}${BOLD}IAM IN TROUBLE -- Game Controller${RESET}                          ${CYAN}|${RESET}"
    echo -e "  ${CYAN}+==============================================================+${RESET}"
    echo ""
    echo -e "  ${WHITE}Usage:${RESET} ${CYAN}./game.sh${RESET} ${YELLOW}<command>${RESET}"
    echo ""
    echo -e "  ${WHITE}Commands:${RESET}"
    echo ""
    echo -e "    ${GREEN}start${RESET}    Launch the game (alert + ticker)"
    echo -e "    ${RED}stop${RESET}     End the session and kill the money ticker"
    echo -e "    ${YELLOW}reset${RESET}    Full reset -- re-provision all attack vectors"
    echo -e "    ${CYAN}status${RESET}   Check your current progress"
    echo -e "    ${DIM}help${RESET}     Show this menu"
    echo ""
    echo -e "  ${WHITE}Gameplay:${RESET}"
    echo ""
    echo -e "    ${DIM}1.${RESET} ${WHITE}./game.sh start${RESET}           -- Begin the escape room"
    echo -e "    ${DIM}2.${RESET} ${WHITE}aws --endpoint-url=...${RESET}    -- Fix the cloud (Levels 1 & 2)"
    echo -e "    ${DIM}3.${RESET} ${WHITE}nano attacker_policy.json${RESET}  -- Fix IAM policy (Level 3)"
    echo -e "    ${DIM}4.${RESET} ${WHITE}./verify.sh <level>${RESET}       -- Check your work"
    echo -e "    ${DIM}5.${RESET} ${WHITE}./game.sh stop${RESET}            -- End session"
    echo ""
    ;;

esac
