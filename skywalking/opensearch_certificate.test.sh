#!/bin/ash

apk add --update openssl && \
    openssl genrsa -out /data/root-ca-key.pem 2048 && \
    openssl req -new -x509 -sha256 -key /data/root-ca-key.pem -out /data/root-ca.pem -days 730 && \
    openssl x509 -outform der -in /data/root-ca.pem -out /data/certificate.der && \
    keytool -storepass 'changeit' -genkey -alias bmc -keyalg RSA -keystore /data/KeyStore.jks -keysize 2048 && \
    keytool -storepass 'changeit' -import -file /data/certificate.der -keystore /data/KeyStore.jks && \
    chmod 777 -R /data
