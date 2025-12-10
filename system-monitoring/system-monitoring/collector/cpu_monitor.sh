#!/bin/bash

# Resolve script directory and ensure logs directory exists (robust relative path)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/../logs"
mkdir -p "$LOG_DIR"
LOG="$LOG_DIR/cpu.log"
ERROR="$LOG_DIR/alerts.log"

CPU_LOAD=$(top -bn1 2>/dev/null | grep "Cpu(s)" | awk '{print $2 + $4}')
if [ -z "$CPU_LOAD" ]; then
    CPU_LOAD="0.0"
fi
CPU_TEMP=$(sensors 2>/dev/null | grep -oP '\+?\d+(\.\d+)?°C' | head -n1 | tr -d '+°C' || true)
if [ -z "$CPU_TEMP" ]; then
    # Try alternate common formats (some sensors output 'xx.x C' without degree symbol)
    CPU_TEMP=$(sensors 2>/dev/null | grep -oP '\d+\.\d+(?= C)' | head -n1 || true)
fi
if [ -z "$CPU_TEMP" ]; then
    CPU_TEMP="N/A"
fi

echo "$(date) | CPU Load: $CPU_LOAD% | Temp: $CPU_TEMP" >> "$LOG"

LOAD_INT=${CPU_LOAD%.*}

if [ "$LOAD_INT" -gt 80 ]; then
    echo "$(date) | ALERT: CPU Load High ($CPU_LOAD%)" >> "$ERROR"
    notify-send "CPU Alert" "CPU Load above 80%: $CPU_LOAD%" 2>/dev/null || true
fi
