#!/bin/sh

echo 'Create Certificate Authority: myCA'

echo 'Create a private key'
openssl genrsa -des3 -out myCA.key 2048

echo 'Generate a ROOT Certificate'
openssl req -x509 -new -nodes -key myCA.key -sha256 -days 1825 -out myCA.pem

echo "SSL Certificate Authority successfully created: myCA"