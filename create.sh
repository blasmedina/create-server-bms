#!/bin/bash

DIRECTORY="/data"
# sudo apt-get update
# source install-git.sh
# source install-nodejs.sh
# source install-pm2.sh

pm2 delete all

APPS=$DIRECTORY/*
for i in {0..9}
do
    APP_TEST_NAME="app-00${i}"
    APP_TEST_POST="300${i}"
    source create-app-test.sh
done

source pm2-reload-app.sh
exit 0