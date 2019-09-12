#!/bin/bash

# sysinfo_page - A script to load app

##### Main

APPS=$1/*

if ! hash pm2 2>/dev/null; then
    echo "requires pm2"
    exit 0
fi

for folder in $APPS; do
    appName="$(basename "$folder")"
    echo "Processing $folder..."
    pm2 start $folder/index.js --name $appName --watch
done