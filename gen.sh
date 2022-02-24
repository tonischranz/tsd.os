name=$1

[ -z "$name" ] && echo enter name && read name

echo "name=$name"

[ -f myRoot.key ] || openssl genrsa -out myRoot.key 2048

[ -f myRoot.crt ] || openssl req -x509 -new -nodes -key myRoot.key -sha256 -days 3650 -out myRoot.crt

[ -f $name.cnf ] || echo "[req]  
default_bits = 2048   
prompt = no  
default_md = sha256 
distinguished_name = dn
[dn]
C=CH
ST=Bern
L=Bern
O=tsd.
emailAddress=viu@tsd.ovh
CN = $name
" > $name.cnf

echo openssl req -new -sha256 -nodes -out $name.csr -newkey rsa:2048 -keyout $name.key -config $name.cnf
openssl req -new -sha256 -nodes -out $name.csr -newkey rsa:2048 -keyout $name.key -config $name.cnf

[ -f $name.ext.cnf ] || echo "authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = $name
" > $name.ext.cnf

echo openssl x509 -req -in $name.csr -CA myRoot.crt -CAkey myRoot.key -CAcreateserial -extfile $name.ext.cnf -out $name.crt -days 3650 -sha256
openssl x509 -req -in $name.csr -CA myRoot.crt -CAkey myRoot.key -CAcreateserial -extfile $name.ext.cnf -out $name.crt -days 3650 -sha256

