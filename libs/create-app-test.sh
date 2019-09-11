#!/bin/bash

# sysinfo_page - A script to create app test

##### Constants

DIRECTORY=$1
APP_TEST_NAME=$2
APP_TEST_POST=$3
PATH_APP=$DIRECTORY/$APP_TEST_NAME

##### Main

echo "Create app test ${PATH_APP} ${POST}"

# sudo rm -rf $PATH_APP
# sudo mkdir -p $PATH_APP
# sudo sh -c "cat >> ${PATH_APP}/index.js" <<-EOF
# const http = require('http');
# const HOSTNAME = '::';
# const PORT = ${APP_TEST_POST};
# const server = http.createServer((req, res) => {
#   res.statusCode = 200;
#   res.setHeader('Content-Type', 'text/plain');
#   res.end("${APP_TEST_NAME}");
# });
# server.listen(PORT, HOSTNAME, () => {
#     console.log("Server run");
# });
# EOF