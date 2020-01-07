# wu-strongswan-docker
### StrongSwan IKEv2 RSA VPN
This is a docker image to help build/deploy [StrongSwan](https://strongswan.org/) IKEv2 (RSA) Tunnel VPN on [Alpine](https://alpinelinux.org/) image.

## Usage
---
Before starting the container you need to have following file on below structure:
* .env
* config/
    * ipsec.conf
    * ipsec.secrets
    * strongswan.conf
    * ipsec.d/
        * private/vpn-server.key
        * certs/vpn-server.crt
        * cacerts/ca.crt



### 1. `.env`
First of all make a copy of `.env.example` to `.env`. At least change **VPN_FQDN** and **CERT_EXPORT_PASS**.
```bash
cp -v .env.example .env
vim .env
```



### 2. Configs
Running `generate_config.sh` will generate `ipsec.conf`, `ipsec.secrets` and `strongswan.conf` files.
```bash
./generate_config.sh
```


### 3. Certs
Running `generate_certs.sh` will generate CA, Server and Client certification and generate a `.p12` format of client with password (CERT_EXPORT_PASS in `.env`) in a [alpine container](https://hub.docker.com/_/alpine/).
```bash
./generate_certs.sh
```


### 4. Build/Run
You can build and run the container manually. or use [docker-compose](https://docs.docker.com/compose/) with a example file: `docker-compose.yml`

##### 4.1. Manually
Build Docker with the following command: 
```bash
docker build --tag=wu-strongswan .
```

You can run it like this:
```bash
docker run -itd \
  --cap-add=NET_ADMIN \
  -p 500:500/udp \
  -p 4500:4500/udp \
  -v /lib/modules:/lib/modules \
  -v /etc/localtime:/etc/localtime \
  -v $PWD/config:/config \
  -v $PWD/config/ipsec.conf:/etc/ipsec.conf \
  -v $PWD/config/ipsec.secrets:/etc/ipsec.secrets \
  -v $PWD/config/ipsec.d:/etc/ipsec.d \
  --sysctl net.ipv4.ip_forward=1 \
  --sysctl net.ipv6.conf.all.forwarding=1 \
  --sysctl net.ipv6.conf.eth0.proxy_ndp=1 \
  --name strongswan-ikev2_1 \
  wu-strongswan 
```

##### 4.2. Docker-Compose
Or you can use docker-compose. Here is a example of `docker-compose.yml`:
```yaml
version: "3"
services:
  strongswan-ikev2_1:
    build: .
    container_name: strongswan-ikev2_1
    cap_add:
      - NET_ADMIN
    ports:
      - ${IKE_PORT}:500/udp
      - ${IPSEC_PORT}:4500/udp
    sysctls:
      - net.ipv4.ip_forward=1
      - net.ipv6.conf.all.forwarding=1
    environment:
      - STRONGSWAN_VERSION=${STRONGSWAN_VERSION}
      - DNS_ADDR1=${DNS_ADDR1}
      - DNS_ADDR2=${DNS_ADDR2}
      - RIGHT_SRC_IP=${RIGHT_SRC_IP}
      - VPN_FQDN=${VPN_FQDN}
      - CERT_EMAIL=${CERT_EMAIL}
      - CERT_ORG=${CERT_ORG}
      - HOSTNAME=${HOSTNAME}
      - CERT_EXPORT_PASS=${CERT_EXPORT_PASS}
    volumes:
      - /lib/modules:/lib/modules
      - /etc/localtime:/etc/localtime
      - ./config:/config
      - ./config/ipsec.conf:/etc/ipsec.conf
      - ./config/ipsec.secrets:/etc/ipsec.secrets
      - ./config/ipsec.d:/etc/ipsec.d
    restart: always
```
By running this it will bring it up:
```bash
docker-compose up -d --build
```
