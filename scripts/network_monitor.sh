#!/bin/bash

# Resolve script directory and ensure logs directory exists
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/../logs"
mkdir -p "$LOG_DIR"
LOG="$LOG_DIR/network.log"
ERROR="$LOG_DIR/alerts.log"

# Pick first non-loopback interface
IFACE=$(awk -F: '$1 !~ /lo/ { gsub(" ", "", $1); print $1; exit }' /proc/net/dev)
if [ -n "$IFACE" ]; then
    # Get RX and TX bytes
    read RX TX < <(awk -v i="$IFACE" -F: '$1 ~ i { gsub(" ", "", $1); print $2 }' /proc/net/dev | awk '{print $1, $9}')
    if [ -n "$RX" ] && [ -n "$TX" ]; then
        # convert to KB
        RX_KB=$((RX/1024))
        TX_KB=$((TX/1024))
        echo "$(date) | IFACE: $IFACE RX:${RX_KB}KB TX:${TX_KB}KB" >> "$LOG"
    else
        echo "$(date) | IFACE: $IFACE RX:N/A TX:N/A" >> "$LOG"
    fi
else
    echo "$(date) | Network: no interface detected" >> "$LOG"
fi
