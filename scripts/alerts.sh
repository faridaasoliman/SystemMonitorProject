#!/bin/bash

# Resolve script directory and ensure logs directory/file exist
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/../logs"
mkdir -p "$LOG_DIR"
ALERTS_FILE="$LOG_DIR/alerts.log"

if [ ! -f "$ALERTS_FILE" ]; then
	echo "# No alerts logged yet" > "$ALERTS_FILE"
fi

echo "==== ACTIVE ALERTS ===="
if [ ! -s "$ALERTS_FILE" ]; then
	echo "(no active alerts)"
else
	cat "$ALERTS_FILE"
fi
