FROM alpine:latest

RUN echo http://nl.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories

RUN apk add -U wireguard-tools

ADD genServerConfig.sh /root/genServerConfig.sh
RUN bash /root/genServerConfig.sh

RUN cat /etc/wireguard/wg0.conf
