#!/bin/bash

DIRECTORY="/data"
# sudo apt-get update
# source install-git.sh
# source install-nodejs.sh
# source install-pm2.sh

pm2 delete all

APPS=$DIRECTORY/*
source create-apps-test.sh

source pm2-reload-app.sh
exit 0