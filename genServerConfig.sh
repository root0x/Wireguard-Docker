#!/bin/bash



#Generate Server Keys

cd /root
umask 077
wg genkey | tee server_private_key | wg pubkey > server_public_key

PORT=$(echo $HOST | grep -o ":.*" | sed 's/://g')
echo $HOST
CONFIG="/etc/wireguard/wg0.conf"

echo "[Interface]"                       >$CONFIG
echo "    Address = 10.10.0.1/24"    >>$CONFIG
echo "    SaveConfig = true"            >>$CONFIG
echo "    PrivateKey = $(cat ./server_private_key)" >>$CONFIG
echo "    ListenPort = 51820"           >>$CONFIG
echo "    PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE" >>$CONFIG
echo "    PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE" >>$CONFIG

echo $CONFIG

# wg-quick up wg0
# systemctl enable wg-quick@wg0.service 
