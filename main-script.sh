#!/bin/bash
set -e

usage() {
  echo "Usage: $0 [-o destination_path] <magnet_link> [<magnet_link> ...]"
  exit 1
}

DEST_PATH="."
while getopts "o:" opt; do
  case "$opt" in
    o) DEST_PATH="$OPTARG" ;;
    *) usage ;;
  esac
done
shift $((OPTIND - 1))

if [ "$#" -eq 0 ] || [ -z "$DEST_PATH" ]; then
  usage
fi

FILE_IN_CONTAINER="/root/Downloads/."

# Build the Docker image
docker build -t torrent-container container

# Run the container, passing all magnet links as arguments, and wait for it to finish
CONTAINER_ID=$(docker run \
  --cap-add=NET_ADMIN \
  --device=/dev/net/tun \
  --privileged \
  --detach=true \
  --tty=true \
  -v $(pwd)/config:/config \
  torrent-container /tmp/torrent-script.sh "$@")

docker wait "$CONTAINER_ID"

# Copy the files out of the container
docker cp "$CONTAINER_ID:$FILE_IN_CONTAINER" "$DEST_PATH"

# Clean up
docker rm "$CONTAINER_ID"
