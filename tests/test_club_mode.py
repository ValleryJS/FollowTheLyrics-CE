import json
import socket
from unittest.mock import patch

from followthelyrics.system.club_mode import ClubMode
from followthelyrics.system.club_mode import godot_executable


def test_club_audio_packet_is_local_and_bounded():
    club = ClubMode()
    listener = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    listener.bind(("127.0.0.1", 0))
    listener.settimeout(1)
    club.PORT = listener.getsockname()[1]

    class Running:
        def poll(self):
            return None

        def terminate(self):
            pass

    club.process = Running()
    try:
        club.send(2.0, -1.0, 0.8)
        payload = json.loads(listener.recvfrom(4096)[0])
        assert payload == {"energy": 1.0, "bass": 0.0, "beat": 0.8}
    finally:
        listener.close()
        club.shutdown()


def test_bundled_renderer_takes_priority(tmp_path):
    runtime = tmp_path / "club_runtime"
    runtime.mkdir()
    executable = runtime / "godot"
    executable.touch()
    with patch("followthelyrics.system.club_mode.sys.platform", "linux"):
        with patch("followthelyrics.system.club_mode.sys._MEIPASS", str(tmp_path), create=True):
            assert godot_executable() == str(executable)
