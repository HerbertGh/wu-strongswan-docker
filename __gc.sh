#!/bin/bash
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source /.env
cd /config
echo 'config setup
  charondebug="ike 1, knl 1, cfg 0"
  uniqueids=never

conn ikev2
    auto=add
    compress=no
    type=tunnel
    keyexchange=ikev2
    fragmentation=yes
    forceencaps=yes
    ike=aes256gcm16-sha384-modp3072!
    esp=aes256gcm16-sha384-modp3072!
    dpdaction=clear
    dpddelay=300s
    rekey=no
    left=%any
    leftid=moon@strongswan.org
    leftcert=vpn-server.crt
    leftsendcert=always
    leftsubnet=0.0.0.0/0
    right=%any
    rightid=%any
    rightauth=eap-tls
    rightdns=1.1.1.1,1.0.0.1
    rightsourceip=10.0.2.0/24
    rightsendcert=never
    eap_identity=%identity' \
  | sed "s/moon@strongswan.org/${VPN_FQDN}/g" \
  | sed "s/1.1.1.1/${DNS_ADDR1}/g" \
  | sed "s/1.0.0.1/${DNS_ADDR2}/g" \
  | awk "{gsub(\"10.0.2.0/24\",\"${RIGHT_SRC_IP}\"); print}" > /config/ipsec.conf
echo ': RSA vpn-server.key' > /config/ipsec.secrets
echo 'libtls {
  suites = TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA
}' > /config/strongswan.conf

