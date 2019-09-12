#!/bin/bash

# sysinfo_page - A script to create app test

##### Main

PATH_APPS=$1
APP_TEST_NAME=$2
APP_TEST_POST=$3
PATH_APP=$PATH_APPS/$APP_TEST_NAME

if [ -d "$PATH_APP" ]; then
    echo "Create app ${PATH_APP}"
    sudo rm -rf $PATH_APP
if

echo "Create app test ${PATH_APP} port ${APP_TEST_POST}"
sudo mkdir -p $PATH_APP
sudo sh -c "cat >> ${PATH_APP}/index.js" <<-EOF
const http = require('http');
const HOSTNAME = '127.0.0.1';
const PORT = ${APP_TEST_POST};
const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end("${APP_TEST_NAME}");
});
server.listen(PORT, HOSTNAME, () => {
    console.log("Server run");
});
EOF