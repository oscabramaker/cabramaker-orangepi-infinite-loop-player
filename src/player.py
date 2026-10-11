#!/usr/bin/python3
"""Os cabramaker v1.0 — @oscabramaker. Cedrus/KMS video appliance."""
import json
import pathlib
import signal

import gi
gi.require_version('Gst', '1.0')
gi.require_version('GstPbutils', '1.0')
from gi.repository import Gst, GstPbutils, GLib

Gst.init(None)
loop = GLib.MainLoop()
pipeline = None
files = sorted(p for p in pathlib.Path('/media/MIDIA/videos').glob('*')
               if p.is_file() and p.suffix.lower() == '.mp4')
index = 0
discoverer = GstPbutils.Discoverer.new(10 * Gst.SECOND)
audio_streams = {}


def start():
    global pipeline
    if not files:
        print('Copie um MP4/H.264 para MIDIA/videos e reinicie.', flush=True)
        return False
    # Set location through a property, so names cannot become pipeline syntax.
    if files[index] not in audio_streams:
        info = discoverer.discover_uri(files[index].resolve().as_uri())
        audio_streams[files[index]] = bool(info.get_audio_streams())
    description = (
        'filesrc name=source ! qtdemux name=demux '
        'demux.video_0 ! queue ! h264parse ! v4l2slh264dec ! queue ! '
        'kmssink name=screen driver-name=sun4i-drm sync=true '
        'plane-properties="props,zpos=(uint)2" render-rectangle="<0,0,1280,720>"')
    if audio_streams[files[index]]:
        description += ' demux.audio_0 ! queue ! decodebin ! audioconvert ! audioresample ! alsasink'
    pipeline = Gst.parse_launch(description)
    pipeline.get_by_name('source').set_property('location', str(files[index]))
    bus = pipeline.get_bus()
    bus.add_signal_watch()
    bus.connect('message', on_message)
    print('PLAY', files[index].name, flush=True)
    pipeline.set_state(Gst.State.PLAYING)
    return False


def on_message(bus, message):
    global index
    if message.type == Gst.MessageType.ERROR:
        error, debug = message.parse_error()
        print('ERROR', str(error), debug, flush=True)
        pipeline.set_state(Gst.State.NULL)
        loop.quit()
    elif message.type == Gst.MessageType.EOS:
        if len(files) == 1 and pipeline.seek_simple(
                Gst.Format.TIME, Gst.SeekFlags.FLUSH | Gst.SeekFlags.KEY_UNIT, 0):
            print('LOOP', flush=True)
        else:
            bus.remove_signal_watch()
            pipeline.set_state(Gst.State.NULL)
            index = (index + 1) % len(files)
            GLib.idle_add(start)


def report():
    if pipeline:
        ok, position = pipeline.query_position(Gst.Format.TIME)
        sink = pipeline.get_by_name('screen')
        stats = sink.get_property('stats').to_string() if sink.find_property('stats') else None
        pathlib.Path('/run/cabramaker/status.json').write_text(json.dumps({
            'file': files[index].name, 'decoder': 'v4l2slh264dec',
            'position': position / Gst.SECOND if ok else None, 'stats': stats}))
    return True


signal.signal(signal.SIGTERM, lambda *_: loop.quit())
signal.signal(signal.SIGINT, lambda *_: loop.quit())
GLib.timeout_add_seconds(5, report)
start()
try:
    loop.run()
finally:
    if pipeline:
        pipeline.set_state(Gst.State.NULL)
