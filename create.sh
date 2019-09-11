#!/bin/bash

# sysinfo_page - A script to create server bms

##### Constants

DIRECTORY="/data"

##### Main

# sudo apt-get update
# source libs/install-git.sh
# source libs/install-nodejs.sh
# source libs/install-pm2.sh

pm2 delete all

source libs/create-apps-test.sh

# source libs/pm2-reload-app.sh $DIRECTORY

exit 0