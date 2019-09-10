#!/bin/bash
apt-get update

# Install GIT
apt-get install -y git

# Install NodeJS
curl -sL https://deb.nodesource.com/setup_10.x | bash -
apt-get install -y nodejs
node -v
npm -v

# Install PM2
npm install -g pm2

rm -rf /data

# Create App 000
mkdir -p /data/app-000
cd /data/app-000
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

pm2 start /data/app-000/index.js

exit 0