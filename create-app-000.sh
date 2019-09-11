#!/bin/bash

# Create App 000
mkdir -p $DIRECTORY/app-000
cd $DIRECTORY/app-000
echo "const http = require('http');
const HOSTNAME = '::';
const PORT = 3000;
const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('App-000');
});
server.listen(PORT, HOSTNAME, () => {
    console.log(`Server running at ${HOSTNAME} on port ${PORT}.`);
});
">>index.js