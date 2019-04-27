#!/bin/bash

apt update
apt install -y linux-headers-$(uname -r)
apt install -y wireguard
