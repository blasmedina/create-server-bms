#!/bin/bash

# sysinfo_page - A script to create app test

##### Main

APP_TEST_PATH=$1
APP_TEST_NAME=$2
APP_TEST_POST=$3

if [ -d "$APP_TEST_PATH" ]; then
    echo "Create app ${APP_TEST_PATH}"
    sudo rm -rf $APP_TEST_PATH
if

echo "Create app test ${APP_TEST_PATH} port ${APP_TEST_POST}"
sudo mkdir -p $APP_TEST_PATH
sudo sh -c "cat >> ${APP_TEST_PATH}/index.js" <<-EOF
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