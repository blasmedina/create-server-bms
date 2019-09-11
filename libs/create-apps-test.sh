#!/bin/bash

# sysinfo_page - A script to create apps test

##### Main

for i in {0..9}
do
    # APP_TEST_NAME="app-00${i}"
    # APP_TEST_POST="300${i}"
    DIRECTORY=${0}
    NAME="app-00${i}"
    POST="300${i}"
    echo "Create app test ${DIRECTORY} ${NAME} ${POST}"
    # source create-app-test.sh $0 $NAME $POST
done