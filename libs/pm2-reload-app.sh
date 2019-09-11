#!/bin/bash

# sysinfo_page - A script to load app

##### Constants

APPS=$0/*

##### Main

for folder in $APPS; do
  appName="$(basename "$folder")"
  echo "Processing $appName..."
  pm2 start $folder/index.js --name $appName
done