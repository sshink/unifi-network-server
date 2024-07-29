FROM ubuntu:latest

LABEL org.opencontainers.image.title="unifi-network-server"
LABEL org.opencontainers.image.description ="A Linux container running the UniFi Network Server"
LABEL org.opencontainers.image.url="https://github.com/sshink/unifi-network-server"
LABEL org.opencontainers.image.source="https://github.com/sshink/unifi-network-server"
LABEL org.opencontainers.image.version="0"

ENV DEBIAN_FRONTEND="noninteractive"

# Based on the following instructions: https://help.ui.com/hc/en-us/articles/220066768-Updating-and-Installing-Self-Hosted-UniFi-Network-Servers-Linux
ADD --chmod=644 https://dl.ui.com/unifi/unifi-repo.gpg /etc/apt/trusted.gpg.d/unifi-repo.gpg

WORKDIR /tmp
# Add dummy package to satisfy dependency
COPY mongodb-org-server_7.0_all.deb .

RUN set -eux; \
  dpkg -i mongodb-org-server_7.0_all.deb; \
  apt-get update; \
  apt-get install --no-install-recommends -y ca-certificates apt-transport-https; \
  echo 'deb [ arch=amd64,arm64 ] https://www.ui.com/downloads/unifi/debian stable ubiquiti' | tee /etc/apt/sources.list.d/100-ubnt-unifi.list; \
  apt-get update; \
  apt-get install unifi -y; \
  rm -rf /var/lib/apt/lists/*; \
  sed  -i 's!nohup /usr/bin/java!/usr/bin/java!1; s!ace.jar start &!ace.jar start!1' /etc/init.d/unifi

COPY system.properties /var/lib/unifi/
WORKDIR /usr/lib/unifi
VOLUME /var/lib/unifi
EXPOSE 8080 8443 8843 8880 10001/udp 3478/udp 6789
# more ports could be needed (https://help.ui.com/hc/en-us/articles/218506997-Required-Ports-Reference)

CMD service unifi start