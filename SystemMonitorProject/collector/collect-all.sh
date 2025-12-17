#!/bin/bash

# Resolve script directory and ensure logs dir absolute
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/../logs"
mkdir -p "$LOG_DIR"
touch "$LOG_DIR/alerts.log" "$LOG_DIR/cron.log"

# Call monitors (use existing filenames)
bash "$SCRIPT_DIR/cpu_monitor.sh"
bash "$SCRIPT_DIR/gpu_monitor.sh"
bash "$SCRIPT_DIR/memory_monitor.sh"
# disk script uses hyphen name in repo
bash "$SCRIPT_DIR/disk-monitor.sh"
# network monitor may not exist; call if present
if [ -f "$SCRIPT_DIR/network_monitor.sh" ]; then
	bash "$SCRIPT_DIR/network_monitor.sh"
fi
bash "$SCRIPT_DIR/system_load.sh"

echo "$(date) | Completed full metrics collection" >> "$LOG_DIR/systemload.log"
echo "$(date) | collect-all triggered" >> "$LOG_DIR/cron.log"

