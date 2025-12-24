
# System Monitor Project

A lightweight Linux system monitoring project built using **Bash scripting** and **Docker**.  
The project monitors system resources such as CPU, memory, disk, network, GPU, and system load, logs the data, and generates basic reports and alerts.

## Features
- CPU, memory, disk, network, GPU, and system load monitoring
- Automatic logging of system metrics
- Alert system for high resource usage
- Simple report generation
- Docker and Docker Compose support
- Modular Bash scripts

## Project Structure
```

SystemMonitorProject/
├── Dockerfile
├── docker-compose.yml
├── README.md
├── logs/
│   ├── cpu.log
│   ├── memory.log
│   ├── disk.log
│   ├── network.log
│   └── systemload.log
├── reports/
│   └── report.txt
└── scripts/
├── collect-all.sh
├── cpu_monitor.sh
├── memory_monitor.sh
├── disk-monitor.sh
├── network_monitor.sh
├── gpu_monitor.sh
├── system_load.sh
└── alerts.sh

````

## Requirements
- Linux OS (tested on Kali Linux)
- Bash shell
- Docker & Docker Compose (optional)
- Zenity or Dialog (for alert notifications)

## How to Run

### Run without Docker
```bash
chmod +x scripts/*.sh
./scripts/collect-all.sh
````

### Run with Docker

```bash
docker-compose up --build
```

## Logs and Reports

* Logs are stored in the `logs/` directory
* Reports are stored in the `reports/` directory
* Each log file contains timestamped system performance data

## Purpose

This project was developed for educational purposes to AASTMT covering:

* Linux system monitoring
* Bash scripting
* Resource and process management
* Docker containerization
* Operating Systems concepts

