#!/usr/bin/env python3
"""
Small HTTP server that links the HTML GUI to the shell collectors and logs.

- Serves the GUI from gui/web
- /metrics runs the collectors and returns the latest values from logs
- /run?cmd=<action> triggers basic actions (currently runs collectors)
"""

from __future__ import annotations

import json
import logging
import os
import re
import subprocess
from datetime import datetime, timezone
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from typing import Any, Dict, Optional
from urllib.parse import parse_qs, urlparse

ROOT = Path(__file__).resolve().parent
WEB_DIR = ROOT / "gui" / "web"
COLLECTOR_DIR = ROOT / "collector"
LOG_DIR = ROOT / "logs"

LOG_DIR.mkdir(parents=True, exist_ok=True)


def run_collectors() -> None:
    """Execute the shell collectors to refresh the logs."""
    script = COLLECTOR_DIR / "collect-all.sh"
    if not script.exists():
        logging.warning("Collector script not found: %s", script)
        return

    try:
        subprocess.run(
            ["bash", str(script)],
            check=False,
            capture_output=True,
            text=True,
            timeout=15,
        )
    except FileNotFoundError:
        logging.error("bash not available; cannot run collectors")
    except subprocess.TimeoutExpired:
        logging.error("Collector script timed out")


def _read_last_line(path: Path) -> Optional[str]:
    """Return the last non-empty line of a file."""
    if not path.exists():
        return None
    try:
        with path.open("r", encoding="utf-8") as f:
            lines = [ln for ln in (line.strip() for line in f) if ln]
        return lines[-1] if lines else None
    except OSError as exc:
        logging.error("Failed reading %s: %s", path, exc)
        return None


def _safe_float(val: Any) -> Optional[float]:
    try:
        return float(val)
    except (TypeError, ValueError):
        return None


CPU_RE = re.compile(r"CPU Load:\s*([\d\.]+)")
CPU_TEMP_RE = re.compile(r"Temp:\s*([\d\.]+)")
MEM_RE = re.compile(r"Memory Usage:\s*(\d+)")
DISK_RE = re.compile(r"Disk Usage:\s*([0-9]+)")
GPU_RE = re.compile(r"GPU Usage:\s*([0-9\.]+)")
LOAD_RE = re.compile(r"System Load:\s*(.+)")
NET_KBPS_RE = re.compile(r"TOTAL_KBPS:([0-9]+)")
NET_FALLBACK_RE = re.compile(r"RX:(\d+)KB\s+TX:(\d+)KB")


def metrics_from_logs() -> Dict[str, Any]:
    cpu_line = _read_last_line(LOG_DIR / "cpu.log")
    mem_line = _read_last_line(LOG_DIR / "memory.log")
    disk_line = _read_last_line(LOG_DIR / "disk.log")
    net_line = _read_last_line(LOG_DIR / "network.log")
    gpu_line = _read_last_line(LOG_DIR / "gpu.log")
    load_line = _read_last_line(LOG_DIR / "systemload.log")

    cpu_match = CPU_RE.search(cpu_line or "")
    cpu_percent = _safe_float(cpu_match.group(1)) if cpu_match else None
    cpu_temp_match = CPU_TEMP_RE.search(cpu_line or "")
    cpu_temp = _safe_float(cpu_temp_match.group(1)) if cpu_temp_match else None

    mem_match = MEM_RE.search(mem_line or "")
    memory_percent = _safe_float(mem_match.group(1)) if mem_match else None

    disk_match = DISK_RE.search(disk_line or "")
    disk_percent = _safe_float(disk_match.group(1)) if disk_match else None

    net_match = NET_KBPS_RE.search(net_line or "")
    network_kbps = _safe_float(net_match.group(1)) if net_match else None
    if network_kbps is None:
        # Fallback to total KB (not a rate) so the UI still shows something
        net_fallback = NET_FALLBACK_RE.search(net_line or "")
        if net_fallback:
            network_kbps = _safe_float(int(net_fallback.group(1)) + int(net_fallback.group(2)))

    gpu_match = GPU_RE.search(gpu_line or "")
    gpu_percent = _safe_float(gpu_match.group(1)) if gpu_match else None

    load_match = LOAD_RE.search(load_line or "")
    load_avg = load_match.group(1).strip() if load_match else None

    return {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "cpu_percent": cpu_percent,
        "cpu_temp_c": cpu_temp,
        "memory_percent": memory_percent,
        "disk_percent": disk_percent,
        "network_kbps": network_kbps,
        "gpu_percent": gpu_percent,
        "load_avg": load_avg,
        "source": "logs",
    }


class MonitorHandler(SimpleHTTPRequestHandler):
    """Serve static GUI files and JSON endpoints."""

    def __init__(self, *args: Any, **kwargs: Any) -> None:
        super().__init__(*args, directory=str(WEB_DIR), **kwargs)

    def do_GET(self) -> None:
        parsed = urlparse(self.path)
        if parsed.path == "/metrics":
            self.handle_metrics()
            return
        if parsed.path == "/run":
            self.handle_run(parsed)
            return
        super().do_GET()

    def handle_metrics(self) -> None:
        run_collectors()
        payload = metrics_from_logs()
        self._send_json(payload)

    def handle_run(self, parsed) -> None:
        qs = parse_qs(parsed.query)
        cmd = (qs.get("cmd") or [""])[0]
        message = "noop"

        if cmd in {"live", "report"}:
            run_collectors()
            message = "collectors executed"
        elif cmd == "logs":
            message = f"Logs live in {LOG_DIR}"

        self._send_json({"ok": True, "cmd": cmd, "message": message})

    def _send_json(self, payload: Dict[str, Any], status: int = 200) -> None:
        body = json.dumps(payload).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, fmt: str, *args: Any) -> None:  # type: ignore[override]
        logging.info("%s - %s", self.client_address[0], fmt % args)


def main() -> None:
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
    host = os.environ.get("MONITOR_HOST", "0.0.0.0")
    port = int(os.environ.get("MONITOR_PORT", "8000"))
    handler = lambda *args, **kwargs: MonitorHandler(*args, **kwargs)  # noqa: E731

    with ThreadingHTTPServer((host, port), handler) as httpd:
        logging.info("Serving GUI from %s", WEB_DIR)
        logging.info("Collector dir: %s", COLLECTOR_DIR)
        logging.info("Listening on http://%s:%s", host, port)
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            logging.info("Shutting down...")
        httpd.server_close()


if __name__ == "__main__":
    main()

