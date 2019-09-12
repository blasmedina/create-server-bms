#!/bin/bash

# sysinfo_page - A script to config nginx apps

##### Constants

PATH_CONFIG=$1
APP_TEST_NAME=$2
APP_TEST_POST=$3
PATH_CONFIG_FILE=$PATH_CONFIG/conf_${APP_TEST_NAME}.conf

##### Main

echo "Create config nginx app ${PATH_CONFIG_FILE}"
sudo rm $PATH_CONFIG_FILE
sudo sh -c "cat >> ${PATH_CONFIG_FILE}" <<-EOF
location /${APP_TEST_NAME}/ {
    proxy_pass http://localhost:${APP_TEST_POST};
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host \$host;
    proxy_cache_bypass \$http_upgrade;
}
EOF

cat $PATH_FILE