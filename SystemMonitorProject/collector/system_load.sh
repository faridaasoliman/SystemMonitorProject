#!/bin/bash

# Resolve script directory and ensure logs directory exists
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/../logs"
mkdir -p "$LOG_DIR"
LOG="$LOG_DIR/systemload.log"

LOAD=$(uptime | awk -F'load average:' '{ print $2 }')
if [ -z "$LOAD" ]; then
    LOAD="0.00 0.00 0.00"
fi

echo "$(date) | System Load: $LOAD" >> "$LOG"
