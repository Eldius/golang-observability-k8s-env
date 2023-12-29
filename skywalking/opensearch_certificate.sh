#!/bin/ash

apk add --update openssl && \
    openssl x509 -outform der -in /certificate/root-ca.pem -out /data/root-ca.der && \
    openssl x509 -outform der -in /certificate/client.pem -out /data/client.der && \
    keytool -storepass 'changeit' -dname "CN=Eldius, OU=N/A, O=org, L=Rio de Janeiro, S=RJ, C=BR" -genkey -alias bmc -keyalg RSA -keystore /data/KeyStore.jks -keysize 2048 && \
    keytool -storepass 'changeit' -import -alias "root_ca" -file /data/root-ca.der -keystore /data/KeyStore.jks && \
    keytool -storepass 'changeit' -import -alias "client" -file /data/client.der -keystore /data/KeyStore.jks && \
    chown ${USER_ID}:${USER_ID} -R /data
