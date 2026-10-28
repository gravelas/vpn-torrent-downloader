#!/bin/bash
set -e

if [ "$#" -eq 0 ]; then
  echo "Usage: $0 \"<magnet_link>\" [\"<magnet_link>\" ...]"
  exit 1
fi

# Start transmission-daemon in the background
transmission-daemon --foreground &
TRANS_PID=$!

# Wait for transmission-daemon to start
sleep 5

# Add each magnet link to Transmission
for MAGNET_LINK in "$@"; do
  transmission-remote --add "$MAGNET_LINK"
done

echo "Added $# magnet link(s). Waiting for all downloads to finish..."

while true; do
  PERCENTS=$(transmission-remote --torrent all --info | grep "Percent Done:" | awk '{print $3}')
  COUNT=$(echo "$PERCENTS" | grep -c . || true)
  DONE=$(echo "$PERCENTS" | grep -cx "100%" || true)
  if [ "$COUNT" -gt 0 ] && [ "$DONE" -eq "$COUNT" ]; then
    echo "All downloads finished."
    break
  fi
  sleep 10
done
