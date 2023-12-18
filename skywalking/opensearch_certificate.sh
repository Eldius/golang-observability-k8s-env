#!/bin/ash

apk add --update openssl && \
    openssl x509 -outform der -in /certificate/root-ca.pem -out /data/certificate.der && \
    keytool -storepass 'changeit' -genkey -alias bmc -keyalg RSA -keystore /data/KeyStore.jks -keysize 2048 && \
    keytool -storepass 'changeit' -import -file /data/certificate.der -keystore /data/KeyStore.jks && \
    chmod 777 -R /data
