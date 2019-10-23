#!/usr/bin/env bash

set -e

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

error() {
    echo ${RED}"Error: $@"${RESET} >&2
}

create_file() {
    local CONTENT=$1
    local PATH_FILE=$2
    local DEBUG=$3
    echo "${BLUE}SAVE:${PATH_FILE}${RESET}"
    echo "${BOLD}$CONTENT${RESET}"
    # if ! [ -z ${DEBUG} ]; then
    #     if [ $DEBUG = true ]; then
    #         local DIR_FILE="$(dirname -- $PATH_FILE)"
    #         if ! [[ -d "$DIR_FILE" ]]; then
    #             mkdir -p $DIR_FILE
    #         fi
    #         echo "$CONTENT" >> "${PATH_FILE}"
    #     fi    
    # fi
    echo
}

get_public_ip() {
    local PUBLIC_IP=$(dig @resolver1.opendns.com ANY myip.opendns.com +short)
    echo "$PUBLIC_IP"
}

main() {
    local DOMAIN="blasmedina.cl"
    local PATH_BIND_ZONES="/etc/bind/zones"
    create_zone
}

create_zone() {
    local DATE=$(date '+%Y%m%d')
    local IP=$(get_public_ip)
    local SERIAL="${DATE}00"
    local HOUR=$((60 * 60))
    local DAY=$(($HOUR * 24))
    local WEEK=$(($DAY * 7))
    local HASH_01=$(head -n 1 $PWD/_acme-challenge-01.txt)
    local HASH_02=$(head -n 1 $PWD/_acme-challenge-02.txt)
    local CONTENT=$(cat <<-EOF
\$ttl $HOUR
${DOMAIN}.  IN      SOA     $HOSTNAME. root.${DOMAIN}. (
                        ${SERIAL} ; serial
                        $(($HOUR * 3)) ; time to refresh
                        $HOUR ; time to retry
                        $WEEK ; time to expire
                        $DAY ; minimum TTL
            )
@                                   IN      NS      ${DOMAIN}.
${DOMAIN}.                      IN      A       ${IP}
ns1.${DOMAIN}.                  IN      A       ${IP}
www                                 IN      CNAME   ${DOMAIN}.
_acme-challenge.${DOMAIN}.  1   IN      TXT     "${HASH_01}"
_acme-challenge.${DOMAIN}.  1   IN      TXT     "${HASH_02}"
EOF
)
    create_file "${CONTENT}" "${PATH_BIND_ZONES}/${DOMAIN}.db"
}

main "$@"
