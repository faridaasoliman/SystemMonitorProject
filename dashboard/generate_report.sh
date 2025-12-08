#!/bin/bash

OUT="../reports/system_report_$(date +%Y%m%d_%H%M).txt"

echo "===== SYSTEM REPORT =====" > "$OUT"
echo "" >> "$OUT"

echo "[ CPU ]" >> "$OUT"
tail -n 5 ../logs/cpu.log >> "$OUT"

echo "" >> "$OUT"
echo "[ MEMORY ]" >> "$OUT"
tail -n 5 ../logs/memory.log >> "$OUT"

echo "" >> "$OUT"
echo "[ DISK ]" >> "$OUT"
tail -n 5 ../logs/disk.log >> "$OUT"

echo "" >> "$OUT"
echo "[ NETWORK ]" >> "$OUT"
tail -n 5 ../logs/network.log >> "$OUT"

echo "" >> "$OUT"
echo "Report saved to: $OUT"
