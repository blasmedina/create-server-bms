#!/bin/bash
apt-get update

# Install GIT
apt-get install -y git

# Install NodeJS
curl -sL https://deb.nodesource.com/setup_10.x | bash -
apt-get install -y nodejs
node -v
npm -v

# Install PM2
npm install -g pm2

rm -rf /data

# Create App 000
source createApp000.sh

FILES=/data/*
for f in $FILES; do
  echo "Processing $f file..."
  # take action on each file. $f store current file name
  # pm2 start /data/app-000/index.js
done

exit 0