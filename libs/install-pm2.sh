#!/bin/bash

# sysinfo_page - A script to install pm2

##### Main

if ! hash npm 2>/dev/null; then
    echo "requires npm"
    exit 0
fi

if hash nodejs 2>/dev/null; then
    pm2 -v
else
    sudo npm install - g pm2
fi