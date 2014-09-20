#!/bin/bash
FQDN=$1

# make directories to work from
mkdir -p certs/{server,client,ca,tmp}

# Create your very own Root Certificate Authority
openssl genrsa \
  -out certs/ca/my-root-ca.key.pem \
  2048

# Self-sign your Root Certificate Authority
# Since this is private, the details can be as bogus as you like
openssl req \
  -x509 \
  -new \
  -nodes \
  -key certs/ca/my-root-ca.key.pem \
  -days 3652 \
  -out certs/ca/my-root-ca.crt.pem \
  -subj "/C=US/ST=Utah/L=Provo/O=ACME Signing Authority Inc/CN=example.com"



# Create a Device Certificate for each domain,
# such as example.com, *.example.com, awesome.example.com
# NOTE: You MUST match CN to the domain name or ip address you want to use
openssl genrsa \
  -out certs/server/my-server.key.pem \
  2048

# Create a request from your Device, which your Root CA will sign
openssl req -new \
  -key certs/server/my-server.key.pem \
  -out certs/tmp/my-server.csr.pem \
  -subj "/C=US/ST=Utah/L=Provo/O=ACME Service/CN=${FQDN}"

# Sign the request from Device with your Root CA
# -CAserial certs/ca/my-root-ca.srl
openssl x509 \
  -req -in certs/tmp/my-server.csr.pem \
  -CA certs/ca/my-root-ca.crt.pem \
  -CAkey certs/ca/my-root-ca.key.pem \
  -CAcreateserial \
  -out certs/server/my-server.crt.pem \
  -days 1095

# Create a public key, for funzies
openssl rsa \
  -in certs/server/my-server.key.pem \
  -pubout -out certs/client/my-server.pub



#
#
# Create a Device Certificate for each trusted client
# such as example.net, *.example.net, awesome.example.net
# NOTE: You MUST match CN to the domain name or ip address you want to use
openssl genrsa \
  -out certs/client/my-app-client.key.pem \
  2048

# Create a trusted client cert
openssl req -new \
  -key certs/client/my-app-client.key.pem \
  -out certs/tmp/my-app-client.csr.pem \
  -subj "/C=US/ST=Utah/L=Provo/O=ACME App Client/CN=client.example.net"

# Sign the request from Trusted Client with your Root CA
# -CAserial certs/ca/my-root-ca.srl
openssl x509 \
  -req -in certs/tmp/my-app-client.csr.pem \
  -CA certs/ca/my-root-ca.crt.pem \
  -CAkey certs/ca/my-root-ca.key.pem \
  -CAcreateserial \
  -out certs/client/my-app-client.crt.pem \
  -days 1095

# Create a public key, for funzies
openssl rsa \
  -in certs/client/my-app-client.key.pem \
  -pubout -out certs/client/my-app-client.pub

# Put things in their proper place
rsync -a certs/ca/my-root-ca.crt.pem certs/server/
rsync -a certs/ca/my-root-ca.crt.pem certs/client/
