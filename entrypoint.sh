#!/bin/bash
wg-quick up wg0

clients=$(wg show | grep peer | awk '{print $2}')
echo $clients
files=($(cat /root/clients/*/*.pub))
echo > /root/last-ip.txt

for i in "${files[@]}"
do
    if [[ $i =~ $clients ]]
    then
	ip="10.10.0."$(expr $(cat /root/last-ip.txt | tr "." " " | awk '{print $4}') + 2)
	wg set wg0 peer $i allowed-ips $ip/32
	echo $ip > /root/last-ip.txt
    fi	
done

tail -f /dev/null
