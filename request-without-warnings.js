#!/usr/bin/env node
'use strict';

var https = require('https')
  , fs = require('fs')
  , path = require('path')
  , ca = fs.readFileSync(path.join(__dirname, 'client', 'my-private-root-ca.crt.pem'))
  , port = process.argv[2] || 4443
  ;

var options = {
  host: 'local.ldsconnect.org'
, port: port
, path: '/'
, ca: ca
};
options.agent = new https.Agent(options);

https.request(options, function(res) {
  res.pipe(process.stdout);
}).end();
