#!/bin/bash

# Resolve script directory and ensure logs directory exists
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/../logs"
mkdir -p "$LOG_DIR"
LOG="$LOG_DIR/memory.log"
ERROR="$LOG_DIR/alerts.log"

MEM=$(free -m | awk 'NR==2{printf "%.0f", $3*100/$2 }')

echo "$(date) | Memory Usage: $MEM%" >> "$LOG"

if [ "$MEM" -gt 80 ]; then
    echo "$(date) | ALERT: High Memory Usage ($MEM%)" >> "$ERROR"
    notify-send "Memory Alert" "Memory usage above 80%: $MEM%" 2>/dev/null || true
fi
