#!/bin/bash

# Resolve script directory; allow override for shared logs
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_LOG_DIR="$SCRIPT_DIR/../logs"
LOG_DIR="${LOG_DIR_OVERRIDE:-$DEFAULT_LOG_DIR}"
mkdir -p "$LOG_DIR"
LOG="$LOG_DIR/disk.log"
ERROR="$LOG_DIR/alerts.log"

DISK=$(df -h / | awk 'NR==2{print $5}')
NUM=${DISK%\%}

if [ -z "$NUM" ]; then
    NUM=0
    DISK="0%"
fi

echo "$(date) | Disk Usage: $DISK" >> "$LOG"

if [ "$NUM" -gt 90 ]; then
    echo "$(date) | ALERT: Disk usage high ($DISK)" >> "$ERROR"
    notify-send "Disk Alert" "Disk usage above 90%: $DISK" 2>/dev/null || true
fi

# SMART check (may require sudo and appropriate device name)
if command -v smartctl >/dev/null 2>&1; then
    SMART_STATUS=$(sudo smartctl -H /dev/sda 2>/dev/null | grep "PASSED" || true)
    if [ -z "$SMART_STATUS" ]; then
        echo "$(date) | ALERT: SMART Failure" >> "$ERROR"
        notify-send "Disk Alert" "SMART test FAILED!" 2>/dev/null || true
    fi
fi
