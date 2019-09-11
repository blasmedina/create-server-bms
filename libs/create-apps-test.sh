#!/bin/bash

# sysinfo_page - A script to create apps test

##### Constants

DIRECTORY=$1

##### Main

for i in {0..9}
do
    source $PWD/libs/create-app-test.sh $DIRECTORY "app-00${i}" "300${i}"
done