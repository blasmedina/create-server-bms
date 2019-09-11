#!/bin/bash
DIRECTORY="/data"
# apt-get update
# source install-git.sh
# source install-nodejs.sh
# source install-pm2.sh
# rm -rf $DIRECTORY
# source create-app-000.sh

pm2 delete all

FILES=$DIRECTORY/*
source pm2-reload-app.sh

exit 0