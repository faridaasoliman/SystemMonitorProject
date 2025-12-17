#!/bin/bash

# Resolve script directory; allow override for shared logs
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_LOG_DIR="$SCRIPT_DIR/../logs"
LOG_DIR="${LOG_DIR_OVERRIDE:-$DEFAULT_LOG_DIR}"
mkdir -p "$LOG_DIR"
LOG="$LOG_DIR/network.log"
ERROR="$LOG_DIR/alerts.log"
PREV_SAMPLE="$LOG_DIR/network.prev"

# Pick first non-loopback interface
IFACE=$(awk -F: '$1 !~ /lo/ { gsub(" ", "", $1); print $1; exit }' /proc/net/dev)
if [ -n "$IFACE" ]; then
    # Get RX and TX bytes (cumulative since boot)
    read RX TX < <(awk -v i="$IFACE" -F: '$1 ~ i { gsub(" ", "", $1); print $2 }' /proc/net/dev | awk '{print $1, $9}')
    if [ -n "$RX" ] && [ -n "$TX" ]; then
        # convert to KB for logging
        RX_KB=$((RX/1024))
        TX_KB=$((TX/1024))

        # Compute simple KB/s using previous sample if present
        RX_KBPS=0
        TX_KBPS=0
        TOTAL_KBPS=0
        NOW=$(date +%s)
        if [ -f "$PREV_SAMPLE" ]; then
            read PREV_TS PREV_RX PREV_TX < "$PREV_SAMPLE"
            DT=$((NOW - PREV_TS))
            if [ "$DT" -gt 0 ]; then
                RX_KBPS=$(( (RX - PREV_RX) / 1024 / DT ))
                TX_KBPS=$(( (TX - PREV_TX) / 1024 / DT ))
                [ "$RX_KBPS" -lt 0 ] && RX_KBPS=0
                [ "$TX_KBPS" -lt 0 ] && TX_KBPS=0
            fi
            TOTAL_KBPS=$((RX_KBPS + TX_KBPS))
        fi

        echo "$NOW $RX $TX" > "$PREV_SAMPLE"
        echo "$(date) | IFACE: $IFACE RX:${RX_KB}KB TX:${TX_KB}KB RX_KBPS:${RX_KBPS} TX_KBPS:${TX_KBPS} TOTAL_KBPS:${TOTAL_KBPS}" >> "$LOG"
    else
        echo "$(date) | IFACE: $IFACE RX:N/A TX:N/A" >> "$LOG"
    fi
else
    echo "$(date) | Network: no interface detected" >> "$LOG"
    echo "$(date) | IFACE:none RX:0KB TX:0KB RX_KBPS:0 TX_KBPS:0 TOTAL_KBPS:0" >> "$LOG"
fi
