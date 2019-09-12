#!/bin/bash

# sysinfo_page - A script to create apps test

##### Constants

START=0

##### Main

PATH_APPS=$1
END=$2
PATH_CONFIG_NGINX_APPS=$3

sudo mkdir -p $PATH_CONFIG_NGINX_APPS

pm2 delete all
sudo rm -rf $PATH_APPS

echo "Create apps (${END}) test ${PATH_APPS} ${PATH_CONFIG_NGINX_APPS}"
for (( i=$START; i<=$END; i++ ))
do
    APP_NAME="app-00${i}"
    APP_POST="300${i}"
    source $PWD/libs/create-app-test.sh $PATH_APPS $APP_NAME $APP_POST
    source $PWD/libs/config-nginx-app.sh $PATH_CONFIG_NGINX_APPS $APP_NAME $APP_POST
done