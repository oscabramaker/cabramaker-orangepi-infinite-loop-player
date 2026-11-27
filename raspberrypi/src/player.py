#!/usr/bin/python3
"""Os cabramaker 1.0 — @oscabramaker. Raspberry Pi VLC/KMS launcher."""
import json
import os
from pathlib import Path
import signal
import subprocess
import time

MEDIA = Path('/media/MIDIA/videos')
STATE = Path('/run/cabramaker/player.json')
child = None
stopping = False


def playlist(directory=MEDIA):
    return sorted((p for p in directory.iterdir()
                   if p.is_file() and p.suffix.lower() == '.mp4'),
                  key=lambda p: (p.name.casefold(), p.name)) if directory.is_dir() else []


def command(files):
    return ['/usr/bin/cvlc', '--intf=dummy', '--no-video-title-show',
            '--no-osd', '--fullscreen', '--loop', '--no-random',
            '--no-media-library', '--no-one-instance',
            '--vout=drm_vout', '--drm-vout-display=HDMI-A-1',
            '--drm-vout-mode=1280x720@60', '--drm-vout-window=fullscreen',
            '--avcodec-hw=any', '--aout=alsa',
            '--alsa-audio-device=sysdefault:CARD=vc4hdmi',
            '--', *(str(p.resolve()) for p in files)]


def stop(signum, frame):
    global stopping
    stopping = True
    if child is not None and child.poll() is None:
        child.terminate()


def main():
    global child
    signal.signal(signal.SIGTERM, stop)
    signal.signal(signal.SIGINT, stop)
    while not stopping:
        files = playlist()
        STATE.parent.mkdir(parents=True, exist_ok=True)
        STATE.write_text(json.dumps({'files': [p.name for p in files],
                                    'status': 'starting' if files else 'waiting-for-mp4'}))
        if not files:
            time.sleep(2)
            continue
        child = subprocess.Popen(command(files), env={**os.environ, 'HOME': '/home/kiosk'})
        STATE.write_text(json.dumps({'files': [p.name for p in files],
                                    'status': 'running', 'pid': child.pid}))
        child.wait()
        if not stopping:
            time.sleep(3)


if __name__ == '__main__':
    main()
