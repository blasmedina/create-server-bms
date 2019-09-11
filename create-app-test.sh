#!/bin/bash

DIR_INIT=$PWD
# Create App Test
sudo mkdir -p $DIRECTORY/$APP_TEST_NAME
cd $DIRECTORY/$APP_TEST_NAME
sudo sh -c "cat >> ${DIRECTORY}/${APP_TEST_NAME}/index.js" <<-EOF
const http = require('http');
const HOSTNAME = '::';
const PORT = ${APP_TEST_POST};
const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end(${APP_TEST_NAME});
});
server.listen(PORT, HOSTNAME, () => {
    console.log("Server run");
});
EOF
cd $DIR_INIT