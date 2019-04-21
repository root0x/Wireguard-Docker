#!/bin/bash


cd /root
mkdir -p clients/$1
wg genkey | tee clients/$1/$1.priv | wg pubkey > clients/$1/$1.pub
key=$(cat clients/$1/$1.priv) 
ip="10.10.0."$(expr $(cat /root/last-ip.txt | tr "." " " | awk '{print $4}') + 2)
echo "[Interface]
# set address to next address
Address = $ip/32
PrivateKey = $key

[Peer]
PublicKey = $(cat /root/server_public_key)
Endpoint = $HOST
# Route only vpn trafic through vpn
AllowedIPs = 10.10.0.0/24
# Route ALL traffic through vpn
#AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 21" > clients/$1/wg0.conf
echo $ip > /root/last-ip.txt
sudo wg set wg0 peer $(cat clients/$1/$1.pub) allowed-ips $ip/32
echo $ip" "$1 | sudo tee -a /etc/hosts
echo clients/$1/wg0.conf
wg show
