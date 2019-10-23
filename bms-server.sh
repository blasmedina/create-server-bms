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
    local NO_DEBUG=$3
    echo "${BLUE}SAVE: \"${PATH_FILE}${RESET}\""
    echo "${BOLD}$CONTENT${RESET}"
    # if ! [ -z ${NO_DEBUG} ]; then
    #     if [ $NO_DEBUG = true ]; then
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

config_bind__zone() {
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

config_bind__named() {
    local CONTENT=$(cat <<-EOF
zone "${DOMAIN}" {
    type master;
    file "${PATH_BIND_ZONES}/${DOMAIN}.db";
};
EOF
)
    create_file "${CONTENT}" "${PATH_BIND}/named.conf.local"
}

config_bind() {
    config_bind__zone
    config_bind__named
}

config_nginx__site_blasmedina() {
    local NAME_SITE="${DOMAIN}"
    local PATH_FILE="${PATH_NGINX_SITES_AVAILABLE}/${NAME_SITE}"
    local CONTENT=$(cat <<-EOF
server {
    listen 80;
    server_name ${DOMAIN};
    # rewrite ^(.*) http://${DOMAIN}\$1 permanent;
    return 301 \$scheme://www.${DOMAIN}\$request_uri;
}
EOF
)
    create_file "${CONTENT}" "${PATH_FILE}"
    # ln -s "${PATH_NGINX_SITES_AVAILABLE}/${NAME_SITE}" "${PATH_NGINX_SITES_ENABLED}/${NAME_SITE}"
}

config_nginx__site_www_blasmedina() {
    local NAME_SITE="www.${DOMAIN}"
    local PATH_FILE="${PATH_NGINX_SITES_AVAILABLE}/${NAME_SITE}"
    local CONTENT=$(cat <<-EOF
server {
    listen 80;
    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;
    server_name ${NAME_SITE};
    
    location ^~ / {
        proxy_pass http://localhost:3000;
${CONTENT_PROXY}
    }
}
EOF
)
    create_file "${CONTENT}" "${PATH_FILE}"
    # ln -s "${PATH_NGINX_SITES_AVAILABLE}/${NAME_SITE}" "${PATH_NGINX_SITES_ENABLED}/${NAME_SITE}"
}

config_nginx() {
    config_nginx__site_blasmedina
    config_nginx__site_www_blasmedina
}

main() {
    local DOMAIN="blasmedina.cl"
    local PATH_BIND="/etc/bind"
    local PATH_BIND_ZONES="${PATH_BIND}/zones"
    local PATH_NGINX="/etc/nginx"
    local PATH_NGINX_APPS="${PATH_NGINX}/default.d"
    local PATH_NGINX_SITES_AVAILABLE="${PATH_NGINX}/sites-available"
    local PATH_NGINX_SITES_ENABLED="${PATH_NGINX}/sites-enabled"
    setup_color
    config_bind
    config_nginx
}

main "$@"
