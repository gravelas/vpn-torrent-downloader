#!/bin/bash
set -e

# Build the Docker image
docker build -t torrent-container container

# Get the ExpressVPN API key from the environment
EXPRESSVPN_API_KEY=$(cat .env | grep EXPRESSVPN_API_KEY | cut -d '=' -f2)

# Run the container, passing the magnet link as an argument
MAGNET_LINK="$1"
if [ -z "$MAGNET_LINK" ]; then
  echo "Usage: $0 <magnet_link> [destination_path]"
  exit 1
fi

FILE_IN_CONTAINER="/root/Downloads/."
DEST_PATH="${2:-.}"

if [ -z "$DEST_PATH" ]; then
  echo "Usage: $0 <magnet_link> [destination_path]"
  exit 1
fi

# Run the container and wait for it to finish
CONTAINER_ID=$(docker run -e MAGNET_LINK=$MAGNET_LINK \
  -e ACTIVATION_CODE=$EXPRESSVPN_API_KEY \
  --cap-add=NET_ADMIN \
  --device=/dev/net/tun \
  --privileged \
  --detach=true \
  --tty=true \
  torrent-container /tmp/torrent-script.sh "$MAGNET_LINK")

docker wait "$CONTAINER_ID"

# Copy the file out of the container
docker cp "$CONTAINER_ID:$FILE_IN_CONTAINER" "$DEST_PATH"

# Clean up
docker rm "$CONTAINER_ID"
