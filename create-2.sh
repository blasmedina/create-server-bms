#!/usr/bin/env bash

##### Functions

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

install_git() {
    if ! command_exists git; then
        sudo apt install -y git
    fi
}

install_bind() {
    if ! command_exists bind9; then
        sudo apt install -y bind9
    fi
}

install_nginx() {
    if ! command_exists git; then
        sudo apt install -y nginx
    fi
}

install_nodejs() {
    if ! command_exists nodejs; then
        curl -sL https://deb.nodesource.com/setup_10.x | bash -
        sudo apt install -y nodejs
    fi
}

install_pm2() {
    if ! command_exists pm2; then
        sudo npm install --global pm2
    fi
}

content_to_file() {
    local CONTENT=$1
    local PATH=$2
    echo "${BLUE}SAVE:${PATH}${RESET}"
    echo "${BOLD}$CONTENT${RESET}"
    echo
    # echo "$CONTENT" >> "${PATH}"
}

config_nginx_app() {
    local PATH_APP=$1
    local PORT_APP=$2
    local NAME_APP="$(basename -- $PATH_APP)"
    local PATH_NGINX_APP="${PATH_NGINX_APPS}/${NAME_APP}.conf"
    local CONTENT=$(cat <<-EOF
location ^~ /${NAME_APP} {
    proxy_pass http://localhost:${PORT_APP};
${CONTENT_PROXY}
}
EOF
)
    echo "config nginx '${NAME_APP}' PATH:${PATH_NGINX_APP} PORT:${PORT_APP}"
    content_to_file "${CONTENT}" "${PATH_NGINX_APP}"
}

create_app_test() {
    local PATH_APP=$1
    local PORT_APP=$2
    local NAME_APP="$(basename -- $PATH_APP)"
    local CONTENT=$(cat <<-EOF
const http = require('http');
const HOSTNAME = '127.0.0.1';
const PORT = ${PORT_APP};
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
    echo "create '${NAME_APP}' PATH:${PATH_APP} PORT:${PORT_APP}"

    if [ -d "$PATH_APP" ]; then
        rm -rf $PATH_APP
    fi
    mkdir -p $PATH_APP
    content_to_file "${CONTENT}" "${PATH_APP}/index.js"
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

create_apps_test() {
    while true; do
        read -r -p "${BOLD}Please enter number app test: ${RESET}" NUMBER_APPS
        if [[ $NUMBER_APPS =~ ^[0-9]+$ ]]; then
            break;
        fi
    done
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

config_nginx_site_blasmedina() {
    local CONTENT=$(cat <<-EOF
server {
    listen 80;
    server_name ${DOMAIN};
    # rewrite ^(.*) http://${DOMAIN}\$1 permanent;
    return 301 \$scheme://www.${DOMAIN}\$request_uri;
}
EOF
)
    content_to_file "${CONTENT}" "${PATH_NGINX_SITES_AVAILABLE}/${NAME_SITE}"
    # ln -s "${PATH_NGINX_SITES_AVAILABLE}/${NAME_SITE}" "${PATH_NGINX_SITES_ENABLED}/${NAME_SITE}"
}

config_nginx_site_www_blasmedina() {
    local NAME_SITE="www.${DOMAIN}"
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
    content_to_file "${CONTENT}" "${PATH_NGINX_SITES_AVAILABLE}/${NAME_SITE}"
    # ln -s "${PATH_NGINX_SITES_AVAILABLE}/${NAME_SITE}" "${PATH_NGINX_SITES_ENABLED}/${NAME_SITE}"
}

config_nginx_site_apps_blasmedina() {
    local NAME_SITE="apps.${DOMAIN}"
    local CONTENT=$(cat <<-EOF
server {
    listen 80;
    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;
    server_name ${NAME_SITE};

    include ${PATH_NGINX_APPS}/*.conf;

    location ^~ / {
        proxy_pass http://localhost:3001;
${CONTENT_PROXY}
    }
}
EOF
)
    content_to_file "${CONTENT}" "${PATH_NGINX_SITES_AVAILABLE}/${NAME_SITE}"
    # ln -s "${PATH_NGINX_SITES_AVAILABLE}/${NAME_SITE}" "${PATH_NGINX_SITES_ENABLED}/${NAME_SITE}"
}

pm2_autoload_apps() {
    for d in $PATH_APPS/*; do
        if [ -d "$d" ]; then
            local APP_NAME="$(basename "$d")"
            local FILE="${d}/index.js"
            if [ -f "$FILE" ]; then
                echo "pm2 start '${APP_NAME}' PATH:${d}"
                # pm2 start $d/index.js --name $APP_NAME --watch
            else
                echo "not found ${FILE}"
            fi
        fi
    done
}

config_bind_name_blasmedina() {
    local CONTENT=$(cat <<-EOF
zone "${DOMAIN}" {
    type master;
    file "${PATH_BIND_ZONES}/${DOMAIN}.db";
};
EOF
)
    content_to_file "${CONTENT}" "${PATH_BIND}/named.conf.local"
}

config_bind_zones_blasmedina() {
    local DATE=$(date '+%Y%m%d')
    local IP=$(dig @resolver1.opendns.com ANY myip.opendns.com +short)
    local CONTENT=$(cat <<-EOF
\$ttl $((60*60))
${DOMAIN}.  IN      SOA     $HOSTNAME. root.${DOMAIN}. (
                        ${DATE}01 ; serial
                        $((60*60*3)) ; time to refresh
                        $((60*60)) ; time to retry
                        $((60*60*24*7)) ; time to expire
                        $((60*60*24)) ) ; minimum TTL
@                                   IN      NS      ${DOMAIN}.
${DOMAIN}.                      IN      A       ${IP}
ns1.${DOMAIN}.                  IN      A       ${IP}
www                                 IN      CNAME   ${DOMAIN}.
apps                                IN      CNAME   ${DOMAIN}.
_acme-challenge.${DOMAIN}.  1   IN      TXT     "cfl9U4aJbzfatSG9jyL_JQl6lV6hRtXzGcUPXqsVcOY"
_acme-challenge.${DOMAIN}.  1   IN      TXT     "WF4_xGNJ5Li6TSlzfHdiKcaOTa9g_A8GNBxTa4Wfhx0"
EOF
)
    content_to_file "${CONTENT}" "${PATH_BIND_ZONES}/${DOMAIN}.db"
}

config_nginx() {
    # sudo service nginx stop
    # mkdir -p $PATH_NGINX_APPS
    config_nginx_site_blasmedina
    config_nginx_site_www_blasmedina
    config_nginx_site_apps_blasmedina
}

config_bind() {
    config_bind_name_blasmedina
    config_bind_zones_blasmedina
}

install() {
    install_git
    install_bind
    install_nodejs
    install_nginx
    install_pm2
}

create_menu() {
    header
    options=(
        "Install"
        "Clean Path App"
        "Create App Test"
        "Config Nginx"
        "Config Bind"
        "Autoload App PM2"
        "Quit")
    PS3="${BOLD}Please enter your choice [1-${#options[@]}]: ${RESET}"
    select opt in "${options[@]}"; do
        case $opt in
            "Install")
                install
                ;;
            "Clean Path App")
                rm -rf $PATH_APPS
                ;;
            "Create App Test")
                create_apps_test
                ;;
            "Config Nginx")
                config_nginx
                ;;
            "Config Bind")
                config_bind
                ;;
            "Autoload App PM2")
                pm2_autoload_apps
                ;;
            "Quit")
                break
                ;;
            *) echo "invalid option $REPLY";;
        esac
    done
}

header() {
    tput reset
    cat <<-EOF
    ▄▄▄▄· • ▌ ▄ ·. .▄▄ · 
    ▐█ ▀█▪·██ ▐███▪▐█ ▀. 
    ▐█▀▀█▄▐█ ▌▐▌▐█·▄▀▀▀█▄
    ██▄▪▐███ ██▌▐█▌▐█▄▪▐█
    ·▀▀▀▀ ▀▀  █▪▀▀▀ ▀▀▀▀ 
EOF
}

main() {
    
    echo
    local SCRIPT_DIR=$(pwd)
    local DOMAIN="blasmedina.cl"
    local PATH_APPS="${SCRIPT_DIR}/apps"
    local PATH_NGINX_APPS="/etc/nginx/default.d"
    local PATH_NGINX_SITES_AVAILABLE="/etc/nginx/sites-available"
    local PATH_NGINX_SITES_ENABLED="/etc/nginx/sites-enabled"
    local PATH_BIND_ZONES="/etc/bind/zones"
    local CONTENT_PROXY=$(cat <<-EOF
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
EOF
)

    setup_color
    create_menu
}

##### Main

main "$@"