FROM ubuntu:latest

ENV DEBIAN_FRONTEND="noninteractive"

# Based on the following instructions: https://help.ui.com/hc/en-us/articles/220066768-Updating-and-Installing-Self-Hosted-UniFi-Network-Servers-Linux
ADD --chmod=644 https://dl.ui.com/unifi/unifi-repo.gpg /etc/apt/trusted.gpg.d/unifi-repo.gpg

WORKDIR /tmp
# Add dummy package to satisfy dependency
COPY mongodb-org-server_7.0_all.deb .

RUN \
  dpkg -i mongodb-org-server_7.0_all.deb && \
  apt-get update && \
  apt-get install --no-install-recommends -y ca-certificates apt-transport-https && \
  echo 'deb [ arch=amd64,arm64 ] https://www.ui.com/downloads/unifi/debian stable ubiquiti' | tee /etc/apt/sources.list.d/100-ubnt-unifi.list && \
  apt-get update && \
  apt-get install unifi -y && \
  apt-get clean

# add local files
#COPY root/ /

COPY system.properties /var/lib/unifi/
WORKDIR /usr/lib/unifi
VOLUME /var/lib/unifi
EXPOSE 8080 8443 8843 8880 10001/udp 3478/udp 6789
# more ports could be needed (https://help.ui.com/hc/en-us/articles/218506997-Required-Ports-Reference)

ENTRYPOINT service unifi start && /bin/bash
