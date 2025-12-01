# System Monitor Project

A Linux system monitoring tool built using Bash, Docker, and a simple GUI (Zenity/Dialog). 
The project collects system metrics, shows live stats, saves logs, and generates reports.

---

## Features
- CPU, GPU, RAM, Disk, Network, and System Load monitoring
- Log files for all collected metrics
- Alerts for high usage thresholds
- GUI dashboard for easy interaction
- HTML and Markdown report generation
- Docker support for running the system in containers

---

## Tech Used
- Bash scripting
- Docker and Docker Compose
- Zenity or Dialog for GUI
- Optional: Python and InfluxDB for historical tracking

---

## Project Structure
SystemMonitorProject/
│── scripts/            # Monitoring scripts
│── dashboard/          # GUI menu + actions
│── docker/             # Dockerfiles
│── logs/               # Saved logs
│── reports/            # Report templates + output
│── docker-compose.yml
│── README.md

---

## How to Run

### Run locally:
chmod +x scripts/*.sh
chmod +x dashboard/*.sh
./dashboard/menu.sh

### Run with Docker:
sudo docker compose up --build

---

## Team Roles
- Member 1: Monitoring scripts and alert system
- Member 2: Docker setup and infrastructure
- Member 3: GUI development and reporting system

---

## Notes
- This project is built for the AASTMT OS course project
- Tested on Kali Linux running on VMware

