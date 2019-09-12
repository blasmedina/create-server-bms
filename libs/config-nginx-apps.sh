#!/bin/bash

# sysinfo_page - A script to create app test

##### Constants

PATH_CONFIG_NGINX_SERVER=$1
PATH_CONFIG_NGINX_APPS=$2

##### Main

echo "Create config nginx ${PATH_CONFIG_NGINX_SERVER}"
sudo rm $PATH_CONFIG_NGINX_SERVER
sudo sh -c "cat >> ${PATH_CONFIG_NGINX_SERVER}" <<-EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;
    server_name _;

    include ${PATH_CONFIG_NGINX_APPS}/*.conf;
}
EOF

cat $PATH_FILE

# sudo nginx -t
# sudo systemctl restart nginx