#!/bin/bash

# sysinfo_page - A script to create server bms

##### Constants

if [ "$1" == "" ]; then
    echo "Debe ingresar un directorio base"
    exit 0
fi

DIRECTORY=$1

##### Main

# sudo apt-get update
# source libs/install-git.sh
# source libs/install-nodejs.sh
# source libs/install-pm2.sh
pm2 delete all
sudo rm -rf $DIRECTORY
source $PWD/libs/create-apps-test.sh $DIRECTORY 2
# source $PWD/libs/install-nginx.sh
source $PWD/libs/pm2-reload-app.sh $DIRECTORY
exit 0