#!/bin/bash

for f in $FILES; do
  echo "Processing $f file..."
  appName="$(basename "$f")"
  pm2 start $f/index.js --name $appName
done