import os
import sys
import urllib.request
import zipfile
from pathlib import Path

VERSION = "4.7.2"
ROOT = Path(__file__).resolve().parents[1]
TARGET = ROOT / "vendor" / "godot"


def fetch():
    windows = sys.platform == "win32"
    suffix = "win64.exe" if windows else "linux.x86_64"
    filename = f"Godot_v{VERSION}-stable_{suffix}"
    url = (
        "https://github.com/godotengine/godot-builds/releases/download/"
        f"{VERSION}-stable/{filename}.zip"
    )
    target_name = "godot.exe" if windows else "godot"
    TARGET.mkdir(parents=True, exist_ok=True)
    destination = TARGET / target_name
    if destination.is_file():
        return destination

    archive_path = TARGET / "runtime.zip"
    try:
        urllib.request.urlretrieve(url, archive_path)
        with zipfile.ZipFile(archive_path) as archive:
            source_name = next(
                (name for name in archive.namelist() if name.endswith(filename)),
                None,
            )
            if not source_name:
                raise RuntimeError("Godot runtime not found in downloaded archive")
            with archive.open(source_name) as source, destination.open("wb") as out:
                while chunk := source.read(1024 * 1024):
                    out.write(chunk)
        if not windows:
            os.chmod(destination, 0o755)
    finally:
        archive_path.unlink(missing_ok=True)
    print(f"Godot {VERSION} runtime: {destination}")
    return destination


if __name__ == "__main__":
    fetch()
