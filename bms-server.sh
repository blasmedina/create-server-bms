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
    if [ $DEBUG = false ]; then
        local DIR_FILE="$(dirname -- $PATH_FILE)"
        if ! [[ -d "$DIR_FILE" ]]; then
            # echo "${GREEN}CREATE: \"${DIR_FILE}\"${RESET}"
            mkdir -p $DIR_FILE
        fi
        if [[ -f "$PATH_FILE" ]]; then
            # echo "${GREEN}REMOVE: \"${PATH_FILE}\"${RESET}"
            rm $PATH_FILE
        fi
        echo "${GREEN}SAVE: \"${PATH_FILE}\"${RESET}"
        echo "$CONTENT" >> "${PATH_FILE}"
    else
        echo "${GREEN}SAVE: \"${PATH_FILE}\"${RESET}"
        echo "${BOLD}$CONTENT${RESET}"
    fi
    # echo
}

create_link_symbolic() {
    local ORIGIN_PATH=$1
    local DESTINATION_PATH=$2
    if [ $DEBUG = false ]; then
        ln -s $ORIGIN_PATH $DESTINATION_PATH
    fi
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
    echo "${BLUE}CONFIG BIND${RESET}"
    local DATE=$(date '+%Y%m%d')
    local IP=$(get_public_ip)
    local SERIAL="${DATE}06"
    local HOUR=$((60 * 60))
    local DAY=$(($HOUR * 24))
    local WEEK=$(($DAY * 7))
    while read -r line; do
        ACME_CHALLENGE="${ACME_CHALLENGE}_acme-challenge.${DOMAIN}.  1   IN      TXT     \"${line}\"
"
    done < "_acme-challenge.txt"
    ACME_CHALLENGE="${ACME_CHALLENGE}_acme-challenge.${DOMAIN}.  1   IN      TXT     \"${line}\""

    local CONTENT=$(cat <<-EOF
\$ORIGIN ${DOMAIN}.
@  IN      SOA     $HOSTNAME. root.${DOMAIN}. (
                        ${SERIAL} ; serial
                        $(($HOUR * 3)) ; time to refresh
                        $HOUR ; time to retry
                        $WEEK ; time to expire
                        $HOUR ) ; minimum TTL
; main domain name servers
            IN      NS      ns1.${DOMAIN}.
; A records for name servers above
            IN      A       ${IP}
ns1         IN      A       ${IP}
www         IN      CNAME   ${DOMAIN}.
apps        IN      CNAME   ${DOMAIN}.
;
;; https://www.sslforfree.com/
${ACME_CHALLENGE}
EOF
)
    create_file "$IP" "~/ip"
    create_file "${CONTENT}" "/etc/bind/zones/${DOMAIN}.db"
}

config_bind__named() {
    local CONTENT=$(cat <<-EOF
zone "${DOMAIN}" {
    type master;
    file "/etc/bind/zones/${DOMAIN}.db";
};
EOF
)
    create_file "${CONTENT}" "/etc/bind/named.conf.local"
}

config_bind() {
    config_bind__zone
    config_bind__named
}

config_nginx__base() {
    local CONTENT=$(cat <<-EOF
user www-data;
worker_processes 1;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
    worker_connections 512;
    use epoll;
    multi_accept on;
}

http {
    ##
    # Basic Settings
    ##
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    server_tokens off;

    client_body_buffer_size         128k;
    client_max_body_size            10m;
    client_header_buffer_size       1k;
    large_client_header_buffers     4 4k;
    output_buffers                  1 32k;
    postpone_output                 1460;

    client_header_timeout           3m;
    client_body_timeout             3m;
    send_timeout                    3m;

    open_file_cache max=1000 inactive=20s;
    open_file_cache_valid 30s;
    open_file_cache_min_uses 5;
    open_file_cache_errors off;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    ##
    # SSL Settings
    ##
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2; # Dropping SSLv3, ref: POODLE
    ssl_prefer_server_ciphers on;

    ##
    # Logging Settings
    # [ debug | info | notice | warn | error | crit | alert | emerg ] 
    ##
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log warn;

    ##
    # Gzip Settings
    ##
    gzip on;
    gzip_min_length  1000;
    gzip_buffers     4 4k;
    gzip_types       text/html application/x-javascript text/css application/javascript text/javascript text/plain text/xml application/json application/vnd.ms-fontobject application/x-font-opentype application/x-font-truetype application/x-font-ttf application/xml font/eot font/opentype font/otf image/svg+xml image/vnd.microsoft.icon;
    gzip_disable "MSIE [1-6]\.";

    ##
    # Virtual Host Configs
    ##
    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
EOF
)
    create_file "${CONTENT}" "/etc/nginx/nginx.conf"
}

config_nginx__site_redirect() {
    local CONTENT=$(cat <<-EOF
server {
    listen 80;
    listen 443 ssl;
    server_name ${DOMAIN};
    ssl_certificate ${SCRIPT_DIR}/certs/certificate.crt;
    ssl_certificate_key ${SCRIPT_DIR}/certs/private.key;
    return 301 https://www.${DOMAIN}\$request_uri;
}

server {
    listen 80;
    server_name apps.${DOMAIN};
    return 301 https://apps.${DOMAIN}\$request_uri;
}
EOF
)
    create_file "${CONTENT}" "/etc/nginx/sites-available/redirect"
    create_link_symbolic "/etc/nginx/sites-available/redirect" "/etc/nginx/sites-enabled/redirect"
}

config_nginx__site_www_blasmedina() {
    local CONTENT=$(cat <<-EOF
server {
    listen 443 ssl;
    server_name www.${DOMAIN};
    ssl_certificate ${SCRIPT_DIR}/certs/certificate.crt;
    ssl_certificate_key ${SCRIPT_DIR}/certs/private.key;
    
    location ^~ / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF
)
    create_file "${CONTENT}" "/etc/nginx/sites-available/www.${DOMAIN}"
    create_link_symbolic "/etc/nginx/sites-available/www.${DOMAIN}" "/etc/nginx/sites-enabled/www.${DOMAIN}"
}

config_nginx__site_apps_blasmedina() {
    local CONTENT=$(cat <<-EOF
server {
    listen 443 ssl;
    server_name apps.${DOMAIN};
    ssl_certificate ${SCRIPT_DIR}/certs/certificate.crt;
    ssl_certificate_key ${SCRIPT_DIR}/certs/private.key;

    include /etc/nginx/default.d/*.conf;

    location ^~ / {
        return 403;
    }
}
EOF
)
    create_file "${CONTENT}" "/etc/nginx/sites-available/apps.${DOMAIN}"
    create_link_symbolic "/etc/nginx/sites-available/apps.${DOMAIN}" "/etc/nginx/sites-enabled/apps.${DOMAIN}"
}

config_nginx() {
    echo "${BLUE}CONFIG NGINX${RESET}"
    config_nginx__base
    config_nginx__site_redirect
    config_nginx__site_www_blasmedina
    config_nginx__site_apps_blasmedina
}

create_app_test__index() {
    local PATH_APP=$1
    local NAME_APP=$2
    local PORT_APP=$3
    echo "${BLUE}CREATE APP TEST: ${NAME_APP}${RESET}"
    local CONTENT=$(cat <<-EOF
require('dotenv').config();
const http = require('http');
const HOSTNAME = process.env.HOSTNAME || '127.0.0.1';
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

create_app_test__package() {
    local PATH_APP=$1
    local NAME_APP=$2
    local CONTENT=$(cat <<-EOF
{
    "name": "${NAME_APP}",
    "version": "0.1.0",
    "description": "App test",
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
    create_file "${CONTENT}" "${PATH_APP}/package.json"
}

create_app_test__ecosystem() {
    local PATH_APP=$1
    local NAME_APP=$2
    local PORT_APP=$3
    local CONTENT=$(cat <<-EOF
module.exports = {
    apps: [{
        name: "${NAME_APP}",
        script: "./src/index.js",
        // instances: "max",
        env: {
            "POST": ${PORT_APP},
            // "HOSTNAME": "::",
            "NODE_ENV": "production",
        }
    }]
}
EOF
)
    create_file "${CONTENT}" "${PATH_APP}/ecosystem.config.js"
}

install_dependencies() {    
    local PATH_APP=$1
    echo "${BLUE}INSTALL DEPENDENCIES: ${PATH_APP}${RESET}"
    if [ $DEBUG = false ]; then
        cd $PATH_APP && npm i
    fi
}

create_app_test() {
    local PATH_APP=$1
    local NAME_APP=$2
    local PORT_APP=$3
    create_app_test__package $PATH_APP $NAME_APP
    create_app_test__index $PATH_APP $NAME_APP $PORT_APP
    create_app_test__ecosystem $PATH_APP $NAME_APP $PORT_APP
    install_dependencies $PATH_APP
}

config_nginx_app() {
    local NAME_APP=$1
    local PORT_APP=$2
    local PATH_NGINX_APP="/etc/nginx/default.d/${NAME_APP}.conf"
    local CONTENT=$(cat <<-EOF
location ^~ /${NAME_APP} {
    proxy_pass http://localhost:${PORT_APP};
${CONTENT_PROXY}
}
EOF
)
    echo "${BLUE}config nginx NAME:${NAME_APP} PATH:${PATH_NGINX_APP} PORT:${PORT_APP}${RESET}"
    create_file "${CONTENT}" "${PATH_NGINX_APP}"
}

create_apps_test() {
    local NUMBER_APPS=$1
    if [ -z ${NUMBER_APPS} ]; then
        while true; do
            read -r -p "${BOLD}Please enter number app test: ${RESET}" NUMBER_APPS
            if [[ $NUMBER_APPS =~ ^[0-9]+$ ]]; then
                break;
            fi
        done
    fi
    local nd=$(count_number_of_digits_in_a_number $NUMBER_APPS)
    echo "${BLUE}create (${NUMBER_APPS}) apps test in ${PATH_APPS}${RESET}"
    if ! [[ -d "$PATH_APPS" ]]; then
        mkdir -p $PATH_APPS
    fi
    local CURRENT_DIRECTORY_NUMBER=$(find $PATH_APPS/* -maxdepth 0 -type d | wc -l)
    for (( c=0; c<$NUMBER_APPS; c++ )); do
        local i=$(($c + $CURRENT_DIRECTORY_NUMBER))
        local ID=$(printf "%0${nd}d" ${i})
        local NAME_APP="app-test-${ID}"
        local PATH_APP="${PATH_APPS}/${NAME_APP}"
        local PORT_APP=$((3000 + $i))
        echo "${BLUE}create app test \"${NAME_APP}\"${RESET}"
        create_app_test $PATH_APP $NAME_APP $PORT_APP
        config_nginx_app $NAME_APP $PORT_APP
    done
}

clear_path_apps() {
    if [ $DEBUG = false ]; then
        echo "${BLUE}clear path apps${RESET}"
        rm -rf $PATH_APPS
    fi
}

modo_debug() {
    if [ $DEBUG = true ]; then
        cat <<-EOF
${YELLOW}
    ****************
    ** MODO DEBUG **
    ****************
${RESET}
EOF
    fi
}

install__git() {
    if ! command_exists git; then
        sudo apt install -y git
    fi
}

install__bind() {
    if ! command_exists bind9; then
        sudo apt install -y bind9
    fi
}

install__nginx() {
    if ! command_exists nginx; then
        sudo apt install -y nginx
    fi
}

install__nodejs() {
    if ! command_exists nodejs; then
        curl -sL https://deb.nodesource.com/setup_12.x | bash -
        sudo apt install -y nodejs
    fi
}

install__pm2() {
    if ! command_exists pm2; then
        sudo npm install --global pm2
    fi
}

install() {
    if [ $DEBUG = false ]; then
        echo "${BLUE}INSTALL${RESET}"
        install__git
        install__bind
        install__nginx
        install__nodejs
        install__pm2
    fi
}

server__stop() {
    if [ $DEBUG = false ]; then
        echo "${BLUE}SERVER STOP${RESET}"
        sudo service bind9 stop
        sudo service nginx stop
    fi
}

server__reload() {
    if [ $DEBUG = false ]; then
        echo "${BLUE}SERVER RELOAD${RESET}"
        sudo service bind9 reload
        sudo service nginx reload
    fi
}

server__start() {
    if [ $DEBUG = false ]; then
        echo "${BLUE}SERVER START${RESET}"
        sudo service bind9 start
        sudo service nginx start
    fi
    server__reload
}

pm2_apps__stop() {
    echo "${BLUE}APPs STOP${RESET}"
    sudo pm2 delete all
}

pm2_apps__reload() {
    echo "${BLUE}APPs RELOAD${RESET}"
    pm2_apps__stop
    pm2_apps__start
} 

pm2_apps__start() {
    echo "${BLUE}APPs START${RESET}"
    for FOLDER in $PATH_APPS/*; do
        if [ -d "$FOLDER" ]; then
            local APP_NAME="$(basename "$FOLDER")"
            local FILE="${FOLDER}/src/index.js"
            if [ -f "$FILE" ]; then
                echo "pm2 start '${APP_NAME}' PATH:${FOLDER}"
                cd $FOLDER
                if [ -f "${FOLDER}/ecosystem.config.js" ]; then
                    pm2 start
                else
                    pm2 start $d/index.js --name $APP_NAME --watch
                fi
                cd $SCRIPT_DIR
            else
                echo "not found ${FILE}"
            fi
        fi
    done
}

clear_all() {
    if [ $DEBUG = false ]; then
        echo "${BLUE}CLEAR ALL${RESET}"
        if [ -d "$PATH_APPS" ]; then
            rm -rf $PATH_APPS
        fi
        if [ -d "/etc/nginx/default.d" ]; then
            rm -rf /etc/nginx/default.d
        fi
        if [ -d "/etc/bind/zones" ]; then
            rm -rf /etc/bind/zones
        fi
        if [ -d "/etc/nginx/sites-enabled" ]; then
            rm /etc/nginx/sites-enabled/*
        fi
    fi
}

install_apps__process() {
    local LINE=$1
    local OIFS="$IFS"
    IFS='#' read -a array <<< "${line}"
    IFS="$OIFS"
    git clone "${array[0]}" "${PATH_APPS}/${array[1]}"
    install_dependencies "${PATH_APPS}/${array[1]}"
}

install_apps() {
    echo "${BLUE}INSTALL APPS${RESET}"
    while read -r line; do
        install_apps__process $line
    done < "${SCRIPT_DIR}/apps.txt"
    install_apps__process $line
}

main() {
    local DEBUG=false
    local SCRIPT_DIR=$(pwd)
    local DOMAIN="blasmedina.cl"
    local PATH_APPS="~/apps"
    local CONTENT_PROXY=$(cat <<-EOF
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
EOF
)
    setup_color
    modo_debug
    install
    server__stop
    clear_all
    config_bind
    config_nginx
    install_apps
    create_apps_test 3
    server__start
    pm2_apps__reload
}

main "$@"
