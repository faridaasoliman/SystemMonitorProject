#!/bin/bash

while true; do
    clear
    echo "===== System Monitor Menu ====="
    echo "1) Run live monitor"
    echo "2) View logs"
    echo "3) Generate system report"
    echo "4) Exit"
    echo -n "Choose: "
    read CHOICE

    case $CHOICE in
        1) bash scripts/live_monitor.sh ;;
        2) bash scripts/view_logs.sh ;;
        3) bash scripts/generate_report.sh ;;
        4) exit ;;
        *) echo "Invalid option"; sleep 1 ;;
    esac
done
