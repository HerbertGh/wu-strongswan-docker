FROM alpine:latest

MAINTAINER WUAmin <wuamin@gmail.com>

ENV DNS_ADDR1            1.1.1.1
ENV DNS_ADDR2            1.0.0.1
ENV STRONGSWAN_VERSION   5.8.2
ENV HOSTNAME             vpn-ikev2

RUN mount -o remount,rw /
RUN apk --update upgrade --no-cache && \
  apk --update add --no-cache --virtual .build-deps build-base \
    ca-certificates \
    curl \
    curl-dev \
    ip6tables \
    iproute2 \
    iptables-dev \
    openssl \
    openssl-dev \
    gmp \
    gmp-dev && \
  echo -e "nameserver ${DNS_ADDR1}\nnameserver $DNS_ADDR2}" > /etc/resolv.conf && \
  wget https://download.strongswan.org/strongswan-${STRONGSWAN_VERSION}.tar.bz2 -O /tmp/strongswan.tar.bz2 && \
  mkdir -pv /tmp/strongswan && \
  tar xjvf /tmp/strongswan.tar.bz2 -C /tmp/strongswan --strip-components=1 && \
  rm -v /tmp/strongswan.tar.bz2 && \
  cd /tmp/strongswan && \
  ./configure --prefix=/usr --sysconfdir=/etc \
    --libexecdir=/usr/lib \
    --with-ipsecdir=/usr/lib/strongswan \
    --enable-aesni \
    --enable-chapoly \
    --enable-cmd \
    --enable-curl \
    --enable-dhcp \
    --enable-eap-dynamic \
    --enable-eap-identity \
    --enable-eap-md5 \
    --enable-eap-mschapv2 \
    --enable-eap-radius \
    --enable-eap-tls \
    --enable-farp \
    --enable-files \
    --enable-gcm \
    --enable-md4 \
    --enable-newhope \
    --enable-ntru \
    --enable-openssl \
    --enable-sha3 \
    --enable-shared \
    --disable-aes \
    --disable-des \
    --disable-gmp \
    --disable-hmac \
    --disable-ikev1 \
    --disable-md5 \
    --disable-rc2 \
    --disable-sha1 \
    --disable-sha2 \
    --disable-static \
    --enable-eap-ttls \
    --enable-eap-peap \
    --enable-eap-tnc \
    --enable-xauth-eap && \
    make -j && \
    make install && \
    cd ~ && \
    rm -rf /tmp/strongswan/ && \
    apk del build-base curl-dev openssl-dev iptables-dev gmp-dev && \
    rm -rf /var/cache/apk/*

    COPY entrypoint.sh .

EXPOSE 500/udp \
  1701/udp \
  4500/udp

ENTRYPOINT [ "/entrypoint.sh" ]
