#!/bin/bash

bash make-root-ca-and-certificates.sh 'local.ldsconnect.org'

node ./serve.js &

sleep 2

node ./request-without-warnings.js
echo ""
