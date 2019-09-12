#!/bin/bash

# sysinfo_page - A script to create server bms

##### Main

if [ "$1" == "" ]; then
    TARGET_DIRECTORY="/data"
else
    TARGET_DIRECTORY=$1
fi

PATH_CONFIG_NGINX_SERVER="/etc/nginx/sites-available/blasmedina"
PATH_CONFIG_NGINX_APPS="/etc/nginx/default.d"

sudo apt-get update
source $PWD/libs/install-git.sh
source $PWD/libs/install-nodejs.sh
source $PWD/libs/install-pm2.sh
source $PWD/libs/install-nginx.sh

source $PWD/libs/create-apps-test.sh $TARGET_DIRECTORY 2 $PATH_CONFIG_NGINX_APPS
source $PWD/libs/pm2-reload-app.sh $TARGET_DIRECTORY
source $PWD/libs/config-nginx-apps.sh $PATH_CONFIG_NGINX_SERVER $PATH_CONFIG_NGINX_APPS

exit 0