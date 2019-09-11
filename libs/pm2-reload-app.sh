#!/bin/bash

# sysinfo_page - A script to load app

##### Constants

APPS=$1/*

##### Main

for folder in $APPS; do
  appName="$(basename "$folder")"
  echo "Processing $folder..."
  pm2 start $folder/index.js --name $appName --watch
done