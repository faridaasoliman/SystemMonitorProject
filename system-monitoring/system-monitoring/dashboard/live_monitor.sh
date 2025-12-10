#!/bin/bash

while true; do
    clear
    echo "===== LIVE SYSTEM MONITOR ====="
    echo ""
    echo "CPU: $(top -bn1 | grep 'Cpu(s)' | awk '{print $2+$4}')%"
    echo "RAM: $(free -m | awk 'NR==2{printf "%.0f", $3*100/$2 }')%"
    echo "Disk: $(df -h / | awk 'NR==2{print $5}')"
    echo "Load: $(uptime | awk -F'load average:' '{print $2}')"
    echo ""
    echo "Press CTRL+C to exit."
    sleep 2
done
