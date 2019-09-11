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

pm2 delete all

FILES=/data/*
for f in $FILES; do
  echo "Processing $f file..."
  appName="${f##*/}"
  pm2 start $f/index.js --name $appName
done

exit 0