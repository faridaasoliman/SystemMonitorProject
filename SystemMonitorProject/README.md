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
│── collector/          # Bash monitoring scripts
│── gui/web/            # HTML dashboard assets
│── docker/             # Container helpers
│── logs/               # Saved logs written by collectors
│── server.py           # Tiny HTTP server to link GUI + collectors
│── docker-compose.yml
│── README.md

---

## How to Run

### Live HTML dashboard (recommended)
- Requirements: Python 3.8+, Bash (Linux/WSL) so the collectors can read `/proc` and sensors
- Make the collectors executable (first time only):\
  `chmod +x collector/*.sh`
- Start the bridge server that serves the GUI and calls the collectors:\
  `python server.py`\
  (optional) change port with `MONITOR_PORT=9000 python server.py`
- Open `http://localhost:8000` in your browser. The page polls `/metrics` every ~2s; the server runs `collector/collect-all.sh` on each poll and reads the latest values from `logs/*.log`.

### Run collectors manually
```bash
bash collector/collect-all.sh
tail -f logs/*.log
```

### Run with Docker:
Build the image:

```bash
docker build -t system-monitor:latest .
```

### Running GUI (Zenity) inside container
Zenity dialogs need an X server. On a Linux host you can run the container with the host DISPLAY and X11 socket:

```bash
# build
docker build -t system-monitor:latest .

# run with X11 forwarding (Linux host)
docker run -it --rm \
	-e DISPLAY=$DISPLAY \
	-v /tmp/.X11-unix:/tmp/.X11-unix \
	-v $(pwd)/logs:/opt/system-monitor/logs \
	system-monitor:latest
```

Notes:
- On Windows, use WSL or an X server (VcXsrv / Xming) and expose DISPLAY accordingly, or rely on the Python/Tk fallback UI (ensure `python3-tk` is installed).
- If you want to use Zenity from a container in a GUI session, allow the container to access the X server (e.g., `xhost +local:root` on the host before running).

Run the container with logs mounted:

```bash
docker run -d --name system-monitor -v "$(pwd)/logs:/opt/system-monitor/logs" system-monitor:latest
```

If you want SMART device access (may require `--cap-add=SYS_RAWIO` and a device mount):

```bash
docker run -d --name system-monitor --cap-add=SYS_RAWIO --device=/dev/sda -v "$(pwd)/logs:/opt/system-monitor/logs" system-monitor:latest
```

For NVIDIA GPU monitoring use the host's GPU runtime (example):

```bash
docker run -d --gpus all --name system-monitor -v "$(pwd)/logs:/opt/system-monitor/logs" system-monitor:latest
```

There is an example Compose file at `docker/docker-compose.yml` you can adapt.

---

## Team Roles
- Member 1: Monitoring scripts and alert system
- Member 2: Docker setup and infrastructure
- Member 3: GUI development and reporting system

---

## Notes
- This project is built for the AASTMT OS course project
- Tested on Kali Linux running on VMware

