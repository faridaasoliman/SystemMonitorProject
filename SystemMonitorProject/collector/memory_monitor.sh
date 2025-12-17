#!/bin/bash
set -euo pipefail

# Resolve script directory; allow override for shared logs
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_LOG_DIR="$SCRIPT_DIR/../logs"
LOG_DIR="${LOG_DIR_OVERRIDE:-$DEFAULT_LOG_DIR}"
mkdir -p "$LOG_DIR"
LOG="$LOG_DIR/memory.log"
ERROR="$LOG_DIR/alerts.log"

MEM=$(free -m | awk 'NR==2{printf "%.0f", $3*100/$2 }')
if [ -z "$MEM" ]; then
    MEM=0
fi

echo "$(date) | Memory Usage: $MEM%" >> "$LOG"

if [ "$MEM" -gt 80 ]; then
    echo "$(date) | ALERT: High Memory Usage ($MEM%)" >> "$ERROR"
    notify-send "Memory Alert" "Memory usage above 80%: $MEM%" 2>/dev/null || true
fi
