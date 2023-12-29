#!/bin/ash

apk add --update openssl || exit 1

cd /data

# apk add --update openssl && \
    # openssl genrsa -out root-ca-key.pem 2048 && \
    # openssl req -new -x509 -sha256 -key root-ca-key.pem -subj "/C=BR/ST=Rio de Janeiro/L=RJ/O=ORG/OU=UNIT/CN=opensearch.dns.a-record/DNS.1=opensearch/DNS.2=opensearch.cluster.local" -out /data/root-ca.pem -days 730 && \
    # openssl genrsa -out opensearch-key-temp.pem 2048 && \
    # openssl pkcs8 -inform PEM -outform PEM -in opensearch-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out opensearch-key.pem && \
    # openssl req -new -key opensearch-key.pem -subj "/C=BR/ST=Rio de Janeiro/L=RJ/O=ORG/OU=UNIT/CN=opensearch.dns.a-record/DNS.1=opensearch/DNS.2=opensearch.cluster.local" -out opensearch-tls.csr && \
    # echo 'subjectAltName=DNS:opensearch.dns.a-record' > opensearch.ext && \
    # openssl x509 -req -in opensearch.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -sha256 -out opensearch.pem -days 730 -extfile opensearch.ext
    # keytool -storepass 'changeit' -genkey -alias bmc -keyalg RSA -keystore /data/KeyStore.jks -keysize 2048 && \
    # keytool -storepass 'changeit' -import -file /data/certificate.der -keystore /data/KeyStore.jks && \
    # chmod 777 -R /data

echo ""
echo ""
echo "generating root-ca certificates"
echo ""
echo ""

openssl genrsa \
    -out root-ca-key.pem 2048 && \
    openssl req \
        -new \
        -x509 \
        -sha256 \
        -key root-ca-key.pem \
        -subj "/C=BR/ST=Rio de Janeiro/L=RJ/O=ORG/OU=UNIT/CN=opensearch.dns.a-record" \
        -out root-ca.pem \
        -days 730 || exit 1

echo ""
echo ""
echo "generating admin certificates"
echo ""
echo ""

openssl genrsa \
    -out admin-key-temp.pem 2048 && \
    openssl pkcs8 \
        -inform PEM \
        -outform PEM \
        -in admin-key-temp.pem \
        -topk8 \
        -nocrypt \
        -v1 PBE-SHA1-3DES \
        -out admin-key.pem && \
    openssl req \
        -new \
        -key admin-key.pem \
        -subj "/C=BR/ST=Rio de Janeiro/L=RJ/O=ORG/OU=UNIT/CN=opensearch.dns.a-record" \
        -out admin.csr && \
    openssl x509 \
        -req \
        -in admin.csr \
        -CA root-ca.pem \
        -CAkey root-ca-key.pem \
        -CAcreateserial \
        -sha256 \
        -out admin.pem \
        -days 730 || exit 1

echo ""
echo ""
echo "generating node certificates"
echo ""
echo ""

openssl genrsa \
        -out node1-key-temp.pem 2048 && \
    openssl pkcs8 \
        -inform PEM \
        -outform PEM \
        -in node1-key-temp.pem \
        -topk8 \
        -nocrypt \
        -v1 PBE-SHA1-3DES \
        -out node1-key.pem && \
    openssl req \
        -new \
        -key node1-key.pem \
        -out node1.csr \
        -subj "/C=BR/ST=Rio de Janeiro/L=RJ/O=ORG/OU=UNIT/CN=opensearch.dns.a-record" && \
    echo 'subjectAltName=DNS:opensearch.dns.a-record' > node1.ext && \
    openssl x509 \
        -req \
        -in node1.csr \
        -CA root-ca.pem \
        -CAkey root-ca-key.pem \
        -CAcreateserial \
        -sha256 \
        -out node1.pem \
        -days 730 \
        -extfile node1.ext || exit 1


echo ""
echo ""
echo "generating client certificates"
echo ""
echo ""

openssl genrsa \
    -out client-key-temp.pem 2048 && \
    openssl pkcs8 \
        -inform PEM \
        -outform PEM \
        -in client-key-temp.pem \
        -topk8 \
        -nocrypt \
        -v1 PBE-SHA1-3DES \
        -out client-key.pem && \
    openssl req \
        -new \
        -key client-key.pem \
        -subj "/C=BR/ST=Rio de Janeiro/L=RJ/O=ORG/OU=UNIT/CN=opensearch.dns.a-record" \
        -out client.csr
echo 'subjectAltName=DNS:client.dns.a-record' > client.ext
openssl x509 -req -in client.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -sha256 -out client.pem -days 730 -extfile client.ext


rm admin-key-temp.pem
rm admin.csr
rm node1-key-temp.pem
rm node1.csr
rm node1.ext
rm client-key-temp.pem
rm client.csr
rm client.ext

chown ${USER_ID}:${USER_ID} -R /data
