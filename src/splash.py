#!/usr/bin/python3
"""Os cabramaker v1.0 — @oscabramaker. Draw an optional PNG on Linux fb0."""
import fcntl
import mmap
import pathlib
import struct
import time
from PIL import Image, ImageOps


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
        if bpp != 32:
            raise RuntimeError('Expected a 32-bit sun4i framebuffer')
        # Verify channel layout rather than assuming every fb0 is BGRA.
        red, green, blue = [struct.unpack_from('3I', variable, offset) for offset in (32, 44, 56)]
        if (red, green, blue) != ((16, 8, 0), (8, 8, 0), (0, 8, 0)):
            raise RuntimeError('Unsupported framebuffer channel layout')
        stride = int(pathlib.Path('/sys/class/graphics/fb0/stride').read_text())
        with Image.open(source) as image:
            if image.width * image.height > 20_000_000:
                raise ValueError('Splash exceeds 20 megapixels')
            image = ImageOps.contain(image.convert('RGBA'), (width, height))
            canvas = Image.new('RGB', (width, height), 'black')
            canvas.paste(image, ((width - image.width) // 2, (height - image.height) // 2), image)
            pixels = canvas.tobytes('raw', 'BGRX')
        with mmap.mmap(framebuffer.fileno(), stride * virtual_height) as target:
            for row in range(height):
                offset = (row + yoffset) * stride + xoffset * 4
                target[offset:offset + width * 4] = pixels[row * width * 4:(row + 1) * width * 4]
    print('SPLASH', source.name, flush=True)


if __name__ == '__main__':
    try:
        show()
    except Exception as error:
        # A missing or invalid banner must never block video startup.
        print('SPLASH_WARNING', str(error), flush=True)
