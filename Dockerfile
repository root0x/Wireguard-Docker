FROM ubuntu:latest

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -y && \
    apt-get install -y software-properties-common iptables curl iproute2 ifupdown iputils-ping && \
    echo resolvconf resolvconf/linkify-resolvconf boolean false | debconf-set-selections && \
    echo "REPORT_ABSENT_SYMLINK=no" >> /etc/default/resolvconf && \
    add-apt-repository --yes ppa:wireguard/wireguard && \
    apt-get install resolvconf qrencode
RUN apt install -y linux-headers-$(uname -r)
RUN apt install -y wireguard

ADD genServerConfig.sh /root/genServerConfig.sh
ADD genClientConfig.sh /root/genClientConfig.sh
RUN bash /root/genServerConfig.sh
RUN mv /root/genClientConfig.sh /usr/bin/genclient
RUN chmod +x /usr/bin/genclient
RUN rm /root/genServerConfig.sh

COPY entrypoint.sh /root/entrypoint.sh
ENTRYPOINT ["bash" , "/root/entrypoint.sh"]
