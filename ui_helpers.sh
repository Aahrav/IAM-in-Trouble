#!/bin/bash
# ============================================================
# ui_helpers.sh — Shared UI functions
# Guarantees perfect box alignment by programmatic padding.
# ============================================================

# Colors
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

# Box width (inner content between ║ and ║)
BOX_W=58
BOX_BORDER="══════════════════════════════════════════════════════════"

# Print a box top:    ╔════...════╗
box_top() {
    local color="${1:-}"
    echo -e "  ${color}╔${BOX_BORDER}╗${RESET}"
}

# Print a box middle: ╠════...════╣
box_mid() {
    local color="${1:-}"
    echo -e "  ${color}╠${BOX_BORDER}╣${RESET}"
}

# Print a box bottom: ╚════...════╝
box_bot() {
    local color="${1:-}"
    echo -e "  ${color}╚${BOX_BORDER}╝${RESET}"
}

# Print a box line with PERFECT padding:
# Usage: box_ln "border_color" "raw_visible_text" "optional_colored_text"
# If colored_text is provided, it's used for display (must match visible length of raw_visible_text)
# If not provided, raw_visible_text is printed as-is
box_ln() {
    local border_color="${1}"
    local raw_text="${2}"
    local display_text="${3:-$raw_text}"

    local text_len=${#raw_text}
    local pad=$((BOX_W - text_len))
    if [ $pad -lt 0 ]; then pad=0; fi
    local spaces=$(printf '%*s' $pad '')

    echo -e "  ${border_color}║${RESET}${display_text}${spaces}${border_color}║${RESET}"
}

# Typewriter effect with color
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
