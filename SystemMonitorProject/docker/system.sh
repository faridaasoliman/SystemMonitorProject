#!/bin/bash

####################################
# GLOBAL SETUP
####################################
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR/.."
LOG_DIR="$REPO_ROOT/logs"
REPORT_DIR="$REPO_ROOT/reports"

mkdir -p "$LOG_DIR" "$REPORT_DIR"

ALERTS_FILE="$LOG_DIR/alerts.log"
[ -f "$ALERTS_FILE" ] || echo "# No alerts logged yet" > "$ALERTS_FILE"

####################################
# HELPERS
####################################
have_zenity() { command -v zenity >/dev/null 2>&1; }
have_python() { command -v python3 >/dev/null 2>&1; }

gui_msg() {
    local title="$1"; shift
    local msg="$*"
    if have_zenity; then
        zenity --info --title "$title" --no-wrap --text "$msg"
    elif have_python; then
        python3 - <<PY
import tkinter as tk, tkinter.messagebox as mb
root=tk.Tk(); root.withdraw()
mb.showinfo("$title", "$msg")
root.destroy()
PY
    fi
}

####################################
# MONITORS
####################################
monitor_cpu() {
    CPU_LOAD=$(top -bn1 | grep "Cpu(s)" | awk '{print $2+$4}')
    [ -z "$CPU_LOAD" ] && CPU_LOAD="0"
    echo "$(date) | CPU Load: $CPU_LOAD%" >> "$LOG_DIR/cpu.log"
    printf "%s\n" "$CPU_LOAD" > "$LOG_DIR/cpu.current"

    if [ "${CPU_LOAD%.*}" -gt 80 ]; then
        echo "$(date) | ALERT: CPU High ($CPU_LOAD%)" >> "$ALERTS_FILE"
    fi
}

monitor_memory() {
    MEM=$(free -m | awk 'NR==2{printf "%.0f",$3*100/$2}')
    echo "$(date) | Memory Usage: $MEM%" >> "$LOG_DIR/memory.log"
    printf "%s\n" "$MEM" > "$LOG_DIR/memory.current"

    [ "$MEM" -gt 80 ] && echo "$(date) | ALERT: Memory High ($MEM%)" >> "$ALERTS_FILE"
}

monitor_disk() {
    DISK=$(df -h / | awk 'NR==2{print $5}')
    NUM=${DISK%%%}
    echo "$(date) | Disk Usage: $DISK" >> "$LOG_DIR/disk.log"
    printf "%s\n" "$NUM" > "$LOG_DIR/disk.current"

    [ "$NUM" -gt 90 ] && echo "$(date) | ALERT: Disk High ($DISK)" >> "$ALERTS_FILE"
}

monitor_gpu() {
    if command -v nvidia-smi >/dev/null; then
        GPU=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits)
    else
        GPU="N/A"
    fi
    echo "$(date) | GPU Usage: $GPU%" >> "$LOG_DIR/gpu.log"
    printf "%s\n" "$GPU" > "$LOG_DIR/gpu.current"
}

monitor_network() {
    IFACE=$(awk -F: '$1 !~ /lo/ {gsub(" ","",$1);print $1;exit}' /proc/net/dev)
    [ -z "$IFACE" ] && return

    read RX TX < <(awk -v i="$IFACE" -F: '$1~i{print $2}' /proc/net/dev | awk '{print $1,$9}')
    echo "$(date) | $IFACE RX:$((RX/1024))KB TX:$((TX/1024))KB" >> "$LOG_DIR/network.log"
}

monitor_load() {
    LOAD=$(uptime | awk -F'load average:' '{print $2}')
    echo "$(date) | Load:$LOAD" >> "$LOG_DIR/systemload.log"
    printf "%s\n" "$LOAD" > "$LOG_DIR/load.current"
}

run_all_monitors() {
    monitor_cpu
    monitor_memory
    monitor_disk
    monitor_gpu
    monitor_network
    monitor_load
}

####################################
# METRICS JSON
####################################
write_metrics_json() {
cat > "$LOG_DIR/metrics.json" <<EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "cpu": $(cat "$LOG_DIR/cpu.current" 2>/dev/null || echo null),
  "memory": $(cat "$LOG_DIR/memory.current" 2>/dev/null || echo null),
  "disk": $(cat "$LOG_DIR/disk.current" 2>/dev/null || echo null),
  "gpu": "$(cat "$LOG_DIR/gpu.current" 2>/dev/null)",
  "load": "$(cat "$LOG_DIR/load.current" 2>/dev/null)"
}
EOF
}

####################################
# REPORT GENERATOR
####################################
generate_report() {
    OUT="$REPORT_DIR/system_report_$(date +%Y%m%d_%H%M).txt"

    {
        echo "===== SYSTEM REPORT ====="
        echo ""
        echo "[ CPU ]"; tail -n 5 "$LOG_DIR/cpu.log"
        echo ""; echo "[ MEMORY ]"; tail -n 5 "$LOG_DIR/memory.log"
        echo ""; echo "[ DISK ]"; tail -n 5 "$LOG_DIR/disk.log"
        echo ""; echo "[ NETWORK ]"; tail -n 5 "$LOG_DIR/network.log"
    } > "$OUT"

    echo "Report saved to: $OUT"
}

####################################
# LIVE CLI MONITOR
####################################
live_cli_monitor() {
    while true; do
        clear
        echo "===== LIVE SYSTEM MONITOR ====="
        echo "CPU: $(top -bn1 | grep Cpu | awk '{print $2+$4}')%"
        echo "RAM: $(free -m | awk 'NR==2{printf "%.0f",$3*100/$2}')%"
        echo "Disk: $(df -h / | awk 'NR==2{print $5}')"
        echo "Load: $(uptime | awk -F'load average:' '{print $2}')"
        echo ""
        echo "CTRL+C to exit"
        sleep 2
    done
}

####################################
# GUI MENU
####################################
choose() {
    if have_zenity; then
        zenity --list --title "System Monitor" --column Action \
            "Run monitors" "Live monitor" "View alerts" "Generate report" "Launch HTML GUI" "Exit"
    else
        echo "Run monitors"
    fi
}

launch_html_gui() {
    python3 -m http.server 8080 --directory "$REPO_ROOT/web" &
    PID=$!
    xdg-open http://localhost:8080/index.html 2>/dev/null
    gui_msg "HTML GUI" "Running on http://localhost:8080 (PID $PID)"
}

####################################
# MAIN LOOP
####################################
while true; do
    CHOICE=$(choose)
    case "$CHOICE" in
        "Run monitors") run_all_monitors; write_metrics_json ;;
        "Live monitor") live_cli_monitor ;;
        "View alerts") gui_msg "Alerts" "$(cat "$ALERTS_FILE")" ;;
        "Generate report") gui_msg "Report" "$(generate_report)" ;;
        "Launch HTML GUI") launch_html_gui ;;
        "Exit"|*) break ;;
    esac
done
