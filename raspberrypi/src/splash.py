#!/usr/bin/python3
"""Os cabramaker v1.0 â€” @oscabramaker. Draw an optional PNG on Linux fb0."""
import fcntl
import array
import mmap
import pathlib
import struct
import time
import sys
from PIL import Image, ImageOps


def encode_pixels(canvas, bpp, channels):
    """Encode the actual Linux framebuffer layout, including Pi RGB565."""
    red, green, blue = channels
    if bpp == 32 and channels == ((16, 8, 0), (8, 8, 0), (0, 8, 0)):
        return canvas.tobytes('raw', 'BGRX')
    if bpp == 32 and channels == ((0, 8, 0), (8, 8, 0), (16, 8, 0)):
        return canvas.tobytes('raw', 'RGBX')
    if bpp == 16 and channels in (
        ((11, 5, 0), (5, 6, 0), (0, 5, 0)),
        ((0, 5, 0), (5, 6, 0), (11, 5, 0)),
    ):
        raw = canvas.tobytes()
        packed = array.array('H', (
            ((r >> 3) << red[0]) | ((g >> 2) << green[0]) | ((b >> 3) << blue[0])
            for r, g, b in zip(raw[0::3], raw[1::3], raw[2::3])
        ))
        if sys.byteorder != 'little':
            packed.byteswap()
        return packed.tobytes()
    raise RuntimeError(f'Unsupported framebuffer: {bpp} bits, {channels}')


def show():
    source = pathlib.Path('/media/MIDIA/splash.png')
    if not source.is_file():
        return
    # Kernel framebuffer may appear after the storage mount.
    for _ in range(50):
        if pathlib.Path('/dev/fb0').exists():
            break
        time.sleep(0.1)
    with open('/dev/fb0', 'r+b', buffering=0) as framebuffer:
        variable = bytearray(160)
        fcntl.ioctl(framebuffer, 0x4600, variable, True)  # FBIOGET_VSCREENINFO
        width, height, virtual_width, virtual_height, xoffset, yoffset, bpp = struct.unpack_from('7I', variable)
        # Verify channel layout rather than assuming every fb0 is BGRA.
        channels = tuple(struct.unpack_from('3I', variable, offset) for offset in (32, 44, 56))
        if bpp not in (16, 32):
            raise RuntimeError(f'Unsupported framebuffer: {bpp} bits')
        pixel_bytes = bpp // 8
        stride = int(pathlib.Path('/sys/class/graphics/fb0/stride').read_text())
        with Image.open(source) as image:
            if image.width * image.height > 20_000_000:
                raise ValueError('Splash exceeds 20 megapixels')
            image = ImageOps.contain(image.convert('RGBA'), (width, height))
            canvas = Image.new('RGB', (width, height), 'black')
            canvas.paste(image, ((width - image.width) // 2, (height - image.height) // 2), image)
            pixels = encode_pixels(canvas, bpp, channels)
        with mmap.mmap(framebuffer.fileno(), stride * virtual_height) as target:
            for row in range(height):
                offset = (row + yoffset) * stride + xoffset * pixel_bytes
                target[offset:offset + width * pixel_bytes] = pixels[row * width * pixel_bytes:(row + 1) * width * pixel_bytes]
    print('SPLASH', source.name, flush=True)


if __name__ == '__main__':
    try:
        show()
    except Exception as error:
        # A missing or invalid banner must never block video startup.
        print('SPLASH_WARNING', str(error), flush=True)
