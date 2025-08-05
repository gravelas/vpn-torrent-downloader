FROM polkaned/expressvpn

ENV MAGNET_LINK=""

RUN apt-get update && \
    apt-get install -y transmission-daemon transmission-cli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY torrent-script.sh /tmp/torrent-script.sh

RUN echo "net.core.rmem_max = 4194304" >> /etc/sysctl.conf && \
    echo "net.core.wmem_max = 1048576" >> /etc/sysctl.conf && \
    chmod +x /tmp/torrent-script.sh
