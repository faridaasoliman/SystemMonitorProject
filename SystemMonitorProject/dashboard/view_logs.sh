#!/bin/bash

clear
echo "==== Log Viewer ===="
echo "1) CPU"
echo "2) GPU"
echo "3) Memory"
echo "4) Disk"
echo "5) Network"
echo "6) Alerts"
echo "Choose: "
read CH

case $CH in
    1) cat logs/cpu.log ;;
    2) cat logs/gpu.log ;;
    3) cat logs/memory.log ;;
    4) cat logs/disk.log ;;
    5) cat logs/network.log ;;
    6) cat logs/alerts.log ;;
esac

echo ""
read -p "Press enter to return..."
