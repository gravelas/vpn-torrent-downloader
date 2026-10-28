#!/bin/bash
set -e

usage() {
  echo "Usage: $0 [-o destination_path] <magnet_link> [<magnet_link> ...]"
  exit 1
}

DEST_PATH="."
MAGNET_LINKS=()
# -o may appear anywhere, before or after the magnet links
while [ "$#" -gt 0 ]; do
  case "$1" in
    -o)
      [ "$#" -ge 2 ] || usage
      DEST_PATH="$2"
      shift 2
      ;;
    -*) usage ;;
    *)
      MAGNET_LINKS+=("$1")
      shift
      ;;
  esac
done

if [ "${#MAGNET_LINKS[@]}" -eq 0 ] || [ -z "$DEST_PATH" ]; then
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
  torrent-container /tmp/torrent-script.sh "${MAGNET_LINKS[@]}")

docker wait "$CONTAINER_ID"

# Copy the files out of the container
docker cp "$CONTAINER_ID:$FILE_IN_CONTAINER" "$DEST_PATH"

# Clean up
docker rm "$CONTAINER_ID"
