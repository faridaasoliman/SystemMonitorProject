#!/bin/bash

# Resolve script directory and ensure logs directory exists
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/../logs"
mkdir -p "$LOG_DIR"
LOG="$LOG_DIR/gpu.log"
ERROR="$LOG_DIR/alerts.log"

if command -v nvidia-smi >/dev/null 2>&1; then
    GPU_UTIL=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null)
else
    GPU_UTIL="N/A"
fi

echo "$(date) | GPU Usage: $GPU_UTIL%" >> "$LOG"

if [ "$GPU_UTIL" != "N/A" ]; then
    # If numeric, allow alerting; otherwise just log the value
    GPU_INT=${GPU_UTIL%%.*}
    if [ "$GPU_INT" -gt 80 ] 2>/dev/null; then
        echo "$(date) | ALERT: GPU usage high ($GPU_UTIL%)" >> "$ERROR"
        notify-send "GPU Alert" "GPU usage above 80%: $GPU_UTIL%" 2>/dev/null || true
    fi
fi
