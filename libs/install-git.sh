#!/bin/bash

# sysinfo_page - A script to install git

##### Main

if hash git 2>/dev/null; then
    git --version
else
    sudo apt install -y git
fi