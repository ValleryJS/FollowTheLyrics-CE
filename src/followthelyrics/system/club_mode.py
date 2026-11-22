import json
import logging
import os
import shutil
import socket
import subprocess
import sys
import threading
import time
from importlib.resources import files

logger = logging.getLogger(__name__)


def godot_executable():
    bundled = os.path.join(
        getattr(sys, "_MEIPASS", ""),
        "club_runtime",
        "godot.exe" if sys.platform == "win32" else "godot",
    )
    if os.path.isfile(bundled):
        return bundled
    return (
        os.environ.get("FTL_GODOT_PATH")
        or shutil.which("godot")
        or shutil.which("godot4")
    )


class ClubMode:
    PORT = 39671

    def __init__(self):
        self.process = None
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.lock = threading.Lock()
        self.last_send = 0.0

    def running(self):
        return self.process is not None and self.process.poll() is None

    def start(self):
        with self.lock:
            if self.running():
                return True
            executable = godot_executable()
            if not executable:
                logger.warning("Club Mode needs Godot 4 to run")
                return False
            project = files("followthelyrics").joinpath("assets", "club")
            try:
                self.process = subprocess.Popen(
                    [executable, "--path", str(project)],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                )
            except OSError:
                logger.warning("Could not launch Club Mode", exc_info=True)
                return False
            return True

    def stop(self):
        with self.lock:
            if self.running():
                self.process.terminate()
            self.process = None

    def send(self, energy, bass, beat):
        if not self.running():
            return
        now = time.monotonic()
        if now - self.last_send < 0.04 and not beat:
            return
        self.last_send = now
        payload = json.dumps({
            "energy": max(0.0, min(1.0, energy)),
            "bass": max(0.0, min(1.0, bass)),
            "beat": max(0.0, min(1.0, beat)),
        }).encode("utf-8")
        try:
            self.socket.sendto(payload, ("127.0.0.1", self.PORT))
        except OSError:
            logger.debug("Could not send Club Mode audio data", exc_info=True)

    def shutdown(self):
        self.stop()
        self.socket.close()
