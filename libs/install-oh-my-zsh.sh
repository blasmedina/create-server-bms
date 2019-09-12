#!/bin/bash

# sysinfo_page - A script to install zsh

if ! hash curl 2>/dev/null; then
    echo "requires curl"
    exit 0
fi

sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"