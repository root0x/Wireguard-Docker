#!/bin/bash

# If wireguard is not installed then install
if ! [ -x "$(command -v wg)" ]; then
    dpkg --configure -a
    # Install wireguard
    apt update
    # Install kernel header specific to your host machine
    apt install -y linux-headers-$(uname -r)
    apt install -y wireguard


    # Generate server config
    
    if [ ! -f /root/clients/server_public_key ]; then
	cd /root/clients
	umask 077
	wg genkey | tee server_private_key | wg pubkey > server_public_key
    fi

    PORT=$(echo $HOST | grep -o ":.*" | sed 's/://g')
    CONFIG="/etc/wireguard/wg0.conf"

    echo "[Interface]"                       >$CONFIG
    echo "    Address = 10.10.0.1/24"    >>$CONFIG
    echo "    SaveConfig = true"            >>$CONFIG
    echo "    PrivateKey = $(cat /root/clients/server_private_key)" >>$CONFIG
    echo "    ListenPort = 51820"           >>$CONFIG
    echo "    PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE" >>$CONFIG
    echo "    PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE" >>$CONFIG


    wg-quick up wg0
fi




if [ $(find /root/clients/ -type d| wc -l) -gt 1 ]
then
    interfaces=($(ip a | grep wg0))

    if [ -z "$interfaces" ]
    then
	wg-quick up wg0
    fi
    
    
    clients=$(wg show | grep peer | awk '{print $2}')
    files=($(head -n 3 /root/clients/*/wg0.conf | grep "==>\|Address" | awk 'NR % 2 {gsub("/wg0.conf", "", $2); print $2} !(NR % 2) {print $3}'))
    linecount=$(echo ${#files[@]})
    linecount=$(($linecount-1))
    echo > /root/last-ip.txt
    start=0
    end="/*.pub"

    for i in $(seq 0 2 $linecount)
    do
	path=$(echo ${files[i]})
	key=$(cat $path$end )
	
	wg set wg0 peer $key allowed-ips $(echo ${files[i+1]})
	echo $ip > /root/last-ip.txt
	# echo "$i "
    done
fi

tail -f /dev/null
