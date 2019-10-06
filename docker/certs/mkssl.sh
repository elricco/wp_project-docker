
#!/bin/sh

cfg=sslserverconftxt.txt

echo "Create SSL Certificate for $* "

echo "Create a private key"
openssl genrsa -out $*.key 2048

echo "Create CSR and a private key"
#openssl req -newkey rsa:2048 -sha1 -keyout $key.priv -config $cfg -new -out $key.csr
openssl req -new -key $*.key -config $cfg -out $*.csr

echo "Define the Subject Alternative Name (SAN) extension"
touch $*.ext
echo "authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = $*
DNS.2 = $*.192.168.1.19.xip.io" >> $*.ext

openssl x509 -req -in $*.csr -CA myCA.pem -CAkey myCA.key -CAcreateserial \
-out $*.crt -days 1825 -sha256 -extfile $*.ext

echo "SSL Certificate for $* successfully created"