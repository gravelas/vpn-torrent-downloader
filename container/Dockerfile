FROM linuxserver/wireguard

ENV MAGNET_LINK=""

RUN apk update && \
    apk add --no-cache transmission-daemon transmission-cli transmission-remote netcat-openbsd

COPY torrent-script.sh /tmp/torrent-script.sh

ENV TR_CURL_VERBOSE=1

RUN echo "net.core.rmem_max = 4194304" >> /etc/sysctl.conf && \
    echo "net.core.wmem_max = 1048576" >> /etc/sysctl.conf && \
    chmod +x /tmp/torrent-script.sh
