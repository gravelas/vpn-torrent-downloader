#!/bin/bash
set -e

MAGNET_LINK="$1"

if [ -z "$MAGNET_LINK" ]; then
  echo "Usage: $0 \"<magnet_link>\""
  exit 1
fi

# Start transmission-daemon in the background
transmission-daemon --foreground &
TRANS_PID=$!

# Wait for transmission-daemon to start
sleep 5

# Add the magnet link to Transmission
TORRENT_ID=$(transmission-remote --add "$MAGNET_LINK" | grep -oE 'Torrent added.* ([0-9]+)' | awk '{print $NF}')

if [ -z "$TORRENT_ID" ]; then
  # Fallback: get the latest torrent ID
  TORRENT_ID=$(transmission-remote --list | awk 'NR==2 {print $1}')
fi

echo "Magnet link added as torrent ID $TORRENT_ID. Waiting for download to finish..."

while true; do
  STATUS=$(transmission-remote --torrent "$TORRENT_ID" --info | grep "State:" | awk '{print $2}')
  if [ "$STATUS" = "Seeding" ]; then
    echo "Download finished."
    break
  fi
  sleep 10
done

