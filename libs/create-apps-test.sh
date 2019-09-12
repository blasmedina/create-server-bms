#!/bin/bash

# sysinfo_page - A script to create apps test

##### Constants

PATH_APPS=$1
START=0
END=$2
PATH_CONFIG_NGINX_APPS=$3

##### Main

for (( i=$START; i<=$END; i++ ))
do
    source $PWD/libs/create-app-test.sh $PATH_APPS "app-00${i}" "300${i}"
    source $PWD/libs/config-nginx-apps.sh $PATH_CONFIG_NGINX_APPS "app-00${i}" "300${i}"
done