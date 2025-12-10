# Simple placeholder script
import os
logs_dir = '/app/logs'
reports_dir = '/app/reports'
os.makedirs(reports_dir, exist_ok=True)

with open(os.path.join(reports_dir, 'report.txt'), 'w') as f:
    f.write('Report placeholder\n')
    f.write('Sample log files:\n')
    if os.path.exists(logs_dir):
        for file in os.listdir(logs_dir):
            f.write(f'- {file}\n')
