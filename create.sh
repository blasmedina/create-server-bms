#!/bin/bash

# sysinfo_page - A script to create server bms

##### Constants

if [ "$1" == "" ]; then
    echo "Debe ingresar un directorio base"
    exit 0
fi

TARGET_DIRECTORY=$1
PATH_CONFIG_NGINX_SERVER="/etc/nginx/sites-available/blasmedina"
PATH_CONFIG_NGINX_APPS="/etc/nginx/default.d"

##### Main

# sudo apt-get update
# source libs/install-git.sh
# source libs/install-nodejs.sh
# source libs/install-pm2.sh
source $PWD/libs/install-nginx.sh
sudo mkdir -p $PATH_CONFIG_NGINX_APPS

pm2 delete all
sudo rm -rf $TARGET_DIRECTORY
source $PWD/libs/create-apps-test.sh $TARGET_DIRECTORY 2 $PATH_CONFIG_NGINX_APPS
source $PWD/libs/pm2-reload-app.sh $TARGET_DIRECTORY
source $PWD/libs/config-nginx-apps.sh $PATH_CONFIG_NGINX_SERVER $PATH_CONFIG_NGINX_APPS
exit 0