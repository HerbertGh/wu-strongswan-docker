#!/bin/bash
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source /.env
cd /config

mkdir -pv /etc/ipsec.d/aacerts \
          /etc/ipsec.d/acerts \
          /etc/ipsec.d/cacerts \
          /etc/ipsec.d/certs \
          /etc/ipsec.d/crls \
          /etc/ipsec.d/ocspcerts \
          /etc/ipsec.d/private

apk update; apk add openssl

echo '[ req ]
distinguished_name = req_distinguished_name
attributes = req_attributes
[ req_distinguished_name ]
countryName = Country Name (2 letter code)
countryName_min = 2
countryName_max = 2
0.organizationName = Organization Name (eg, company)
commonName = Common Name (eg, fully qualified host name)
commonName_max = 64
countryName_default = CA # Defaults
0.organizationName_default = VPN-SERVER # Defaults
[ req_attributes ]
challengePassword = A challenge password
challengePassword_min = 4
challengePassword_max = 20
[ ca ]
subjectKeyIdentifier = hash
basicConstraints = critical, CA:true
keyUsage = critical, cRLSign, keyCertSign
[ server ]
authorityKeyIdentifier = keyid
subjectAltName = DNS:moon.strongswan.org # Defaults
extendedKeyUsage = serverAuth, 1.3.6.1.5.5.8.2.2
[ client ]
authorityKeyIdentifier = keyid
subjectAltName = email:moon@strongswan.org # Defaults
extendedKeyUsage = serverAuth, 1.3.6.1.5.5.8.2.2' \
  | sed "s/moon@strongswan.org/${CERT_EMAIL}/g" \
  | sed "s/VPN-SERVER/${CERT_ORG}/g" \
  | sed "s/moon.strongswan.org/${VPN_FQDN}/g" \
  > openssl.cnf

openssl genrsa -out ${HOSTNAME}_CA.key 4096
openssl req -x509 -new -nodes -config openssl.cnf -extensions ca -key ${HOSTNAME}_CA.key -days 3650 -out ${HOSTNAME}_CA.crt -subj '/CN=lvde1.wuamin.xyz/O=WU-Services/C=CA'
openssl genrsa -out ${HOSTNAME}_SRV.key 4096
openssl req -new -config openssl.cnf -extensions server -key ${HOSTNAME}_SRV.key -out ${HOSTNAME}_SRV.csr -subj '/CN=lvde1.wuamin.xyz/O=WU-Services/C=CA'
openssl x509 -req -extfile openssl.cnf -extensions server -in ${HOSTNAME}_SRV.csr -CA ${HOSTNAME}_CA.crt -CAkey ${HOSTNAME}_CA.key -CAcreateserial -days 3650 -out ${HOSTNAME}_SRV.crt
openssl genrsa -out ${HOSTNAME}_client.key 4096
openssl req -new -config openssl.cnf -extensions client -key ${HOSTNAME}_client.key -out ${HOSTNAME}_client.csr -subj '/CN=lvde1.wuamin.xyz/O=WU-Services/C=CA'
openssl x509 -req -extfile openssl.cnf -extensions client -in ${HOSTNAME}_client.csr -CA ${HOSTNAME}_CA.crt -CAkey ${HOSTNAME}_CA.key -CAcreateserial -days 3650 -out ${HOSTNAME}_client.crt
openssl pkcs12 -in ${HOSTNAME}_client.crt -inkey ${HOSTNAME}_client.key -certfile ${HOSTNAME}_CA.crt -export -out ${HOSTNAME}_client.p12 -password pass:${CERT_EXPORT_PASS}
cp -v ${HOSTNAME}_CA.crt /etc/ipsec.d/cacerts/ca.crt
cp -v ${HOSTNAME}_SRV.key /etc/ipsec.d/private/vpn-server.key
cp -v ${HOSTNAME}_SRV.crt /etc/ipsec.d/certs/vpn-server.crt
chmod -Rv 755 /etc/ipsec.d/private
chmod -v +r *.crt *.p12

