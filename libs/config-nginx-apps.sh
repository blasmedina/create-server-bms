#!/bin/bash

# sysinfo_page - A script to create app test

##### Main

PATH_CONFIG_NGINX_SERVER=$1
PATH_CONFIG_NGINX_APPS=$2
FILE=/etc/nginx/sites-enabled/blasmedina

if [[ -f "$PATH_CONFIG_NGINX_SERVER" ]]; then
    echo "Delete config nginx app ${PATH_CONFIG_NGINX_SERVER}"
    sudo rm $PATH_CONFIG_NGINX_SERVER
fi

echo "Create config nginx apps ${PATH_CONFIG_NGINX_SERVER}"
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

if [[ -f "$FILE" ]]; then
    sudo rm $FILE
fi

sudo ln -s $PATH_CONFIG_NGINX_SERVER $FILE
# sudo nginx -t
sudo systemctl restart nginx