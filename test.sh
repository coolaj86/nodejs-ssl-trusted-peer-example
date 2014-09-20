#!/bin/bash
FQDN='local.foobar3000.com'
PORT=8043

bash make-root-ca-and-certificates.sh "${FQDN}"
echo ""

echo ""
node ./serve.js 8043 &
NODE_PID=$!
sleep 1

echo ""
echo ""
node ./request-without-warnings.js "${FQDN}" "${PORT}" 
echo -n " - without warnings, love node.js' https"
echo ""
sleep 1

echo ""
./request.sh "${FQDN}" "${PORT}"
echo -n " - without warnings, love cURL"
echo ""
sleep 1

kill ${NODE_PID}
echo ""
