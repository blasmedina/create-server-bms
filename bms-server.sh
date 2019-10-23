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

count_number_of_digits_in_a_number() {
    local nd=0
    local n=$1
    while [ $n -gt 0 ]; do
        n=$(( $n / 10 )) 
        nd=$(( $nd + 1))
    done
    return $nd
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

create_index_app_test() {
    local PATH_APP=$1
    local PORT_APP=$2
    local NAME_APP="$(basename -- $PATH_APP)"
    local CONTENT=$(cat <<-EOF
require('dotenv').config();
const http = require('http');
const HOSTNAME = '127.0.0.1';
const PORT = process.env.POST || ${PORT_APP};
const server = http.createServer((req, res) => {
    res.statusCode = 200;
    res.setHeader('Content-Type', 'text/plain');
    res.end("${NAME_APP}");
});
server.listen(PORT, HOSTNAME, () => {
    console.log("Server run");
});
EOF
)
    create_file "${CONTENT}" "${PATH_APP}/src/index.js"
}

create_package_app_test() {
    local PATH_APP=$1
    local NAME_APP="$(basename -- $PATH_APP)"
    local CONTENT=$(cat <<-EOF
{
    "name": "${NAME_APP}",
    "version": "1.0.0",
    "description": "",
    "main": "./src/index.js",
    "scripts": {
        "test": "echo \"Error: no test specified\" && exit 1"
    },
    "keywords": [],
    "author": "Blas Medina <r.blas.m.c@gmail.com>",
    "license": "ISC",
    "dependencies": {
        "dotenv": "^8.1.0"
    }
}
EOF
)
    create_file "${CONTENT}" "${PATH_APP}/package.js"
}

create_ecosystem_app_test() {
    local PATH_APP=$1
    local PORT_APP=$2
    local NAME_APP="$(basename -- $PATH_APP)"
    local CONTENT=$(cat <<-EOF
module.exports = {
    apps: [{
        name: "${NAME_APP}",
        script: "./src/index.js",
        instances: "max",
        env: {
            "POST": ${PORT_APP},
            "NODE_ENV": "production",
        }
    }]
}
EOF
)
    create_file "${CONTENT}" "${PATH_APP}/ecosystem.config.js"
}

create_app_test() {
    local PATH_APP=$1
    local PORT_APP=$2
    create_index_app_test $PATH_APP $PORT_APP
    create_package_app_test $PATH_APP $PORT_APP
    create_ecosystem_app_test $PATH_APP $PORT_APP
    # npm i
}

create_apps_test() {
    local NUMBER_APPS=$1
    if ! [ -z ${NUMBER_APPS} ]; then
        while true; do
            read -r -p "${BOLD}Please enter number app test: ${RESET}" NUMBER_APPS
            if [[ $NUMBER_APPS =~ ^[0-9]+$ ]]; then
                break;
            fi
        done
    fi
    local nd=$(count_number_of_digits_in_a_number $NUMBER_APPS)
    echo "create (${NUMBER_APPS}) apps test in ${PATH_APPS}"
    if ! [[ -d "$PATH_APPS" ]]; then
        mkdir -p $PATH_APPS
    fi
    local CURRENT_DIRECTORY_NUMBER=$(find $PATH_APPS/* -maxdepth 0 -type d | wc -l)
    for (( c=0; c<$NUMBER_APPS; c++ )); do
        local i=$(($c + $CURRENT_DIRECTORY_NUMBER))
        local ID=$(printf "%0${nd}d" ${i})
        local PATH_APP="${PATH_APPS}/app-test-${ID}"
        local PORT_APP=$((3000 + $i))
        create_app_test $PATH_APP $PORT_APP
        config_nginx_app $PATH_APP $PORT_APP
    done
}

main() {
    local SCRIPT_DIR=$(pwd)
    local DOMAIN="blasmedina.cl"
    local PATH_BIND="/etc/bind"
    local PATH_BIND_ZONES="${PATH_BIND}/zones"
    local PATH_NGINX="/etc/nginx"
    local PATH_NGINX_APPS="${PATH_NGINX}/default.d"
    local PATH_NGINX_SITES_AVAILABLE="${PATH_NGINX}/sites-available"
    local PATH_NGINX_SITES_ENABLED="${PATH_NGINX}/sites-enabled"
    local PATH_APPS="${SCRIPT_DIR}/apps"
    setup_color
    config_bind
    config_nginx
    create_apps_test 2
}

main "$@"
