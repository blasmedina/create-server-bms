#!/bin/bash

# sysinfo_page - A script to create apps test

##### Constants

START=0

##### Main

PATH_APPS=$1
END=$2
PATH_CONFIG_NGINX_APPS=$3

sudo mkdir -p $PATH_CONFIG_NGINX_APPS

if ! hash pm2 2>/dev/null; then
    echo "requires pm2"
    exit 0
fi

pm2 delete all
sudo rm -rf $PATH_APPS

echo "Create apps (${END}) test ${PATH_APPS} ${PATH_CONFIG_NGINX_APPS}"
for (( i=$START; i<=$END; i++ ))
do
    APP_NAME="app-00${i}"
    APP_POST="300${i}"
    APP_PATH="${PATH_APPS}/${APP_NAME}"
    PATH_CONFIG_FILE="${PATH_CONFIG_NGINX_APPS}/${APP_NAME}.conf"
    source $PWD/libs/create-app-test.sh $APP_PATH $APP_NAME $APP_POST
    source $PWD/libs/config-nginx-app.sh $PATH_CONFIG_FILE $APP_NAME $APP_POST
done