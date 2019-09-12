#!/bin/bash

# sysinfo_page - A script to install nodejs

##### Main

if hash nodejs 2>/dev/null; then
    node -v
    npm -v
else
    curl -sL https://deb.nodesource.com/setup_10.x | bash -
    sudo apt install -y nodejs
fi