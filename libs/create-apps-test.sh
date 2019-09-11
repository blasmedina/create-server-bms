#!/bin/bash

# sysinfo_page - A script to create apps test

##### Constants

DIRECTORY_=$1

##### Main

for i in {0..9}
do
    # APP_TEST_NAME="app-00${i}"
    # APP_TEST_POST="300${i}"
    NAME="app-00${i}"
    POST="300${i}"
    echo "${DIRECTORY_}"
    # source $PWD/libs/create-app-test.sh $DIRECTORY $NAME $POST
done