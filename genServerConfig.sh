#!/bin/bash

if [[ -z "${PORT}" ]]; then
    PORT=51820
fi


#Generate Server Keys
umask 077
wg genkey | tee server_private_key | wg pubkey > server_public_key


CONFIG="/etc/wireguard/wg0.conf"

echo "[Interface]"                       >$CONFIG
echo "    Address = 10.100.100.1/16"    >>$CONFIG
echo "    SaveConfig = true"            >>$CONFIG
echo "    PrivateKey = $(cat ./server_private_key)" >>$CONFIG
echo "    ListenPort = $PORT"           >>$CONFIG
echo "    PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE" >>$CONFIG
echo "    PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE" >>$CONFIG
