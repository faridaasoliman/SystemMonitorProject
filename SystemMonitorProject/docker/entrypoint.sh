#!/bin/bash
set -e

SCRIPT_DIR="/opt/system-monitor"
LOG_DIR="$SCRIPT_DIR/logs"

mkdir -p "$LOG_DIR"

# Add cron job to run metrics collection every minute if not present
CRON_JOB="* * * * * root /bin/bash /opt/system-monitor/scripts/collect-all.sh >> /opt/system-monitor/logs/cron.log 2>&1"
if ! grep -Fxq "$CRON_JOB" /etc/crontab; then
    echo "$CRON_JOB" >> /etc/crontab
fi

# Run a single collection at container start
/bin/bash /opt/system-monitor/scripts/collect-all.sh || true

# Start cron in foreground (Debian/Ubuntu)
exec cron -f
