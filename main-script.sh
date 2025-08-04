#!/bin/bash
set -e

# Build the Docker image
docker build -t torrent-container .

# Run the container, passing the magnet link as an argument
MAGNET_LINK="$1"
if [ -z "$MAGNET_LINK" ]; then
  echo "Usage: $0 <magnet_link> <file_to_copy_from_container> [destination_path]"
  exit 1
fi

FILE_IN_CONTAINER="/root/Downloads/"
DEST_PATH="${2:-.}"

if [ -z "$FILE_IN_CONTAINER" ]; then
  echo "Usage: $0 <magnet_link> <file_to_copy_from_container> [destination_path]"
  exit 1
fi

# Run the container and wait for it to finish
CONTAINER_ID=$(docker run -d torrent-container "$MAGNET_LINK")
docker wait "$CONTAINER_ID"

# Copy the file out of the container
docker cp "$CONTAINER_ID:$FILE_IN_CONTAINER" "$DEST_PATH"

# Clean up
docker rm "$CONTAINER_ID"