#!/bin/bash

DIR_INIT=$PWD
# Create App Test
PATH_APP=$DIRECTORY/$APP_TEST_NAME
sudo rm -rf $PATH_APP
sudo mkdir -p $PATH_APP
cd $PATH_APP
sudo sh -c "cat >> ${PATH_APP}/index.js" <<-EOF
const http = require('http');
const HOSTNAME = '::';
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
cd $DIR_INIT