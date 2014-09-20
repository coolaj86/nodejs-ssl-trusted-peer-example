#!/bin/bash
FQDN=$1
PORT=$2

# test without server or client verification
# curl -v -s -k "https://${FQDN}:${PORT}"

# test with server verification only
# curl -v -s "https://${FQDN}:${PORT}" \
# --cacert certs/client/my-root-ca.crt.pem

# test with client verification only
#curl -v -s -k "https://${FQDN}:${PORT}" \
#  --key certs/client/my-app-client.key.pem \
#  --cert certs/client/my-app-client.crt.pem

# test with server and client verification
# For lots of output about the ssl connection try -v
curl -s "https://${FQDN}:${PORT}" \
  --key certs/client/my-app-client.key.pem \
  --cert certs/client/my-app-client.crt.pem \
  --cacert certs/client/my-root-ca.crt.pem
