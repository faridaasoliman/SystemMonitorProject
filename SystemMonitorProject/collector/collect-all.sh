#!/bin/bash

# Resolve script directory and prefer a shared logs directory if available
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_LOG_DIR="$SCRIPT_DIR/../logs"
WIN_LOG_DIR="/mnt/c/Users/HP/OneDrive/Desktop/SystemMonitorProject/logs"

if [ -d "$WIN_LOG_DIR" ]; then
	LOG_DIR="$WIN_LOG_DIR"
else
	LOG_DIR="$DEFAULT_LOG_DIR"
fi

export LOG_DIR_OVERRIDE="$LOG_DIR"
mkdir -p "$LOG_DIR"
touch "$LOG_DIR/alerts.log" "$LOG_DIR/cron.log"

# Helper to run a script and log any stderr to cron.log
run_step() {
	local name="$1"
	shift
	{
		echo "$(date) | START $name"
		"$@"
		RC=$?
		echo "$(date) | END $name rc=$RC"
	} >> "$LOG_DIR/cron.log" 2>&1
}

# Call monitors (use existing filenames)
run_step cpu bash "$SCRIPT_DIR/cpu_monitor.sh"
run_step gpu bash "$SCRIPT_DIR/gpu_monitor.sh"
run_step mem bash "$SCRIPT_DIR/memory_monitor.sh"
# disk script uses hyphen name in repo
run_step disk bash "$SCRIPT_DIR/disk-monitor.sh"
# network monitor may not exist; call if present
if [ -f "$SCRIPT_DIR/network_monitor.sh" ]; then
	run_step net bash "$SCRIPT_DIR/network_monitor.sh"
fi
run_step load bash "$SCRIPT_DIR/system_load.sh"

echo "$(date) | Completed full metrics collection" >> "$LOG_DIR/systemload.log"
echo "$(date) | collect-all triggered" >> "$LOG_DIR/cron.log"

