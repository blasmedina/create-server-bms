#!/bin/bash
apt-get update

# Install GIT
apt-get install -y git

# Install NodeJS
curl -sL https://deb.nodesource.com/setup_10.x | bash -
apt-get install -y nodejs
node -v
npm -v

# Create Env
mkdir /data

# Create App 000
mkdir -p /data/app-000
cat <<EOT >> /data/app-000/app.js
const http = require('http');

const HOSTNAME = '127.0.0.1';
const PORT = 3000;

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('Hello dev.to!\n');
});

server.listen(PORT, HOSTNAME, () => {
  console.log(`Server running at ${HOSTNAME} on port ${PORT}.`);
});
EOT

node /data/app-000/app.js