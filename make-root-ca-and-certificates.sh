#!/bin/bash
FQDN=$1

# make directories to work from
mkdir -p server/ client/ all/

# Create your very own Root Certificate Authority
openssl genrsa \
  -out all/my-private-root-ca.key.pem \
  2048

# Self-sign your Root Certificate Authority
# Since this is private, the details can be as bogus as you like
openssl req \
  -x509 \
  -new \
  -nodes \
  -key all/my-private-root-ca.key.pem \
  -days 1024 \
  -out all/my-private-root-ca.crt.pem \
  -subj "/C=US/ST=Utah/L=Provo/O=ACME Signing Authority Inc/CN=example.com"

# Create a Device Certificate for each domain,
# such as example.com, *.example.com, awesome.example.com
# NOTE: You MUST match CN to the domain name or ip address you want to use
openssl genrsa \
  -out all/my-server.key.pem \
  2048

# Create a request from your Device, which your Root CA will sign
openssl req -new \
  -key all/my-server.key.pem \
  -out all/my-server.csr.pem \
  -subj "/C=US/ST=Utah/L=Provo/O=ACME Tech Inc/CN=${FQDN}"

# Sign the request from Device with your Root CA
openssl x509 \
  -req -in all/my-server.csr.pem \
  -CA all/my-private-root-ca.crt.pem \
  -CAkey all/my-private-root-ca.key.pem \
  -CAcreateserial \
  -out all/my-server.crt.pem \
  -days 500

# Put things in their proper place
rsync -a all/my-server.{key,crt}.pem server/
rsync -a all/my-private-root-ca.crt.pem server/
rsync -a all/my-private-root-ca.crt.pem client/
