#!/bin/bash

DIRECTORY="/data"
# sudo apt-get update
# source install-git.sh
# source install-nodejs.sh
# source install-pm2.sh
rm -rf $DIRECTORY

pm2 delete all

APPS=$DIRECTORY/*
APP_TEST_NAME="app-000"
APP_TEST_POST="3000"
source create-app-test.sh

APP_TEST_NAME="app-001"
APP_TEST_POST="3001"
source create-app-test.sh

source pm2-reload-app.sh
exit 0