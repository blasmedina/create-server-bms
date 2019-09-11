#!/bin/bash

for folder in $APPS; do
  appName="$(basename "$folder")"
  echo "Processing $appName..."
  pm2 start $folder/index.js --name $appName
done