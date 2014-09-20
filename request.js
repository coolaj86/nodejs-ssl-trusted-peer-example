#!/usr/bin/env node
'use strict';

var https = require('https')
  , fs = require('fs')
  , path = require('path')
  , hostname = process.argv[2] || 'local.foobar3000.com'
  , port = process.argv[3] || 8043
  ;

var options = {
  host: hostname
, port: port
, path: '/'
, ca: fs.readFileSync(path.join(__dirname, 'certs', 'client', 'my-root-ca.crt.pem'))
, key: fs.readFileSync(path.join(__dirname, 'certs', 'client', 'my-app-client.key.pem'))
, cert: fs.readFileSync(path.join(__dirname, 'certs', 'client', 'my-app-client.crt.pem'))
};
options.agent = new https.Agent(options);

https.request(options, function(res) {
  res.pipe(process.stdout);
}).end();
