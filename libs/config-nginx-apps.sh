#!/bin/bash

# sysinfo_page - A script to config nginx apps

##### Constants

APPS=$1/*
PATH_FILE=$1/test.conf

##### Main

# for folder in $APPS; do
#   appName="$(basename "$folder")"
#   echo "Processing $folder..."
#   pm2 start $folder/index.js --name $appName --watch
# done
echo "Create config nginx ${PATH_FILE}"
sudo sh -c "cat >> ${PATH_FILE}" <<-EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;
    server_name _;
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

cat $PATH_FILE