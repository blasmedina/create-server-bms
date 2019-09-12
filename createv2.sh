#!/bin/bash

##### Functions

command_exists() {
    command -v "$@" >/dev/null 2>&1
}

setup_color() {
    # Only use colors if connected to a terminal
    if [ -t 1 ]; then
        RED=$(printf '\033[31m')
        GREEN=$(printf '\033[32m')
        YELLOW=$(printf '\033[33m')
        BLUE=$(printf '\033[34m')
        BOLD=$(printf '\033[1m')
        RESET=$(printf '\033[m')
    else
        RED=""
        GREEN=""
        YELLOW=""
        BLUE=""
        BOLD=""
        RESET=""
    fi
}

main() {
    setup_color
    cat <<-EOF
    ${RED}Create Server ${YELLOW}BMS
    EOF
    printf "$RESET"
    exit 1
}

main "$@"