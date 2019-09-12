#!/bin/bash

# sysinfo_page - A script to install nginx

##### Main

if hash nginx 2>/dev/null; then
    sudo nginx -v
else
    sudo apt install -y nginx
fi

