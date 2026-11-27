"""Verify generated image and package public code. Os cabramaker / @oscabramaker."""
from pathlib import Path
import hashlib
import os
import shutil
import struct
import zipfile

version = os.environ['VERSION']
out = Path('out')
name = f'os-cabramaker-raspberrypi3-v{version}.img'
image = out / name


def sha(path):
    h = hashlib.sha256()
    with path.open('rb') as stream:
        while block := stream.read(8 * 1024 * 1024):
            h.update(block)
    return h.hexdigest()


assert image.stat().st_size == 7516192768
with image.open('rb') as stream:
    mbr = stream.read(512)
assert mbr[510:512] == b'\x55\xaa'
assert [(mbr[450+i*16], *struct.unpack_from('<II', mbr, 454+i*16)) for i in range(2)] == [
    (12, 16384, 7323648), (131, 7340032, 7340032)]
expected = sha(image)
actual = hashlib.sha256()
with zipfile.ZipFile(out / (name + '.zip')) as archive:
    assert archive.namelist() == [name]
    with archive.open(name) as stream:
        while block := stream.read(8 * 1024 * 1024):
            actual.update(block)
assert actual.hexdigest() == expected
shutil.copyfile(out / (name + '.packages.tsv'), out / 'packages.tsv')
source = Path('raspberrypi')
code_name = f'os-cabramaker-raspberrypi3-v{version}-codigo.zip'
with zipfile.ZipFile(out / code_name, 'w', zipfile.ZIP_DEFLATED) as archive:
    for path in sorted(source.rglob('*')):
        if not path.is_file() or any(p in ('build', '__pycache__') for p in path.relative_to(source).parts):
            continue
        data = path.read_bytes()
        if path.relative_to(source).as_posix() == 'docs/packages.tsv':
            data = (out / 'packages.tsv').read_bytes()
        archive.writestr('os-cabramaker-raspberrypi3/' + path.relative_to(source).as_posix(), data)
lines = [expected + '  ' + name]
for leaf in [name + '.zip', code_name, 'packages.tsv']:
    lines.append(sha(out / leaf) + '  ' + leaf)
(out / 'SHA256SUMS.txt').write_text('\n'.join(lines) + '\n', encoding='ascii')
print('FILESYSTEMS_AND_ZIP_SHA256_VERIFIED', flush=True)
