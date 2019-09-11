#!/bin/bash

# sysinfo_page - A script to create apps test

##### Constants

DIRECTORY=$1
START=0
END=$2

##### Main

for i in {$START..$END}
do
    source $PWD/libs/create-app-test.sh $DIRECTORY "app-00${i}" "300${i}"
done