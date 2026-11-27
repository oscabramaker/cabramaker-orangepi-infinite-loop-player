"""Publish only manually requested, verified public builds. No private assets."""
from pathlib import Path
import hashlib
import json
import os
import urllib.parse
import urllib.request

version = os.environ['VERSION']
repo = os.environ['GITHUB_REPOSITORY']
tag = f'raspberrypi-v{version}'
prefix = '/repos/' + repo
headers = {'Authorization': 'Bearer ' + os.environ['GITHUB_TOKEN'],
           'Accept': 'application/vnd.github+json', 'User-Agent': 'cabramaker-image-builder',
           'X-GitHub-Api-Version': '2022-11-28'}


def api(method, path, data=None):
    request = urllib.request.Request('https://api.github.com' + path,
        data=json.dumps(data).encode() if data is not None else None,
        headers=headers, method=method)
    with urllib.request.urlopen(request, timeout=120) as response:
        return json.load(response) if response.status != 204 else None


release = next((r for r in api('GET', prefix + '/releases') if r['tag_name'] == tag), None)
notes = Path('.github/raspberrypi-release.md').read_text()
if release is None:
    release = api('POST', prefix + '/releases', {'tag_name': tag, 'target_commitish': os.environ['GITHUB_SHA'],
        'name': f'Os cabramaker {version} — Raspberry Pi 3 B / B+', 'body': notes,
        'draft': True, 'prerelease': False, 'make_latest': 'false'})
assert release['draft'], 'Published versions are immutable: choose a new version.'
for asset in release['assets']:
    api('DELETE', prefix + '/releases/assets/' + str(asset['id']))
leaves = [f'os-cabramaker-raspberrypi3-v{version}.img.zip', 'SHA256SUMS.txt',
          'packages.tsv', f'os-cabramaker-raspberrypi3-v{version}-codigo.zip']
for leaf in leaves:
    path = Path('out') / leaf
    url = release['upload_url'].split('{')[0] + '?name=' + urllib.parse.quote(leaf)
    with path.open('rb') as stream:
        request = urllib.request.Request(url, data=stream, method='POST', headers={**headers,
            'Content-Type': 'application/octet-stream', 'Content-Length': str(path.stat().st_size)})
        with urllib.request.urlopen(request, timeout=180) as response:
            asset = json.load(response)
    h = hashlib.sha256(path.read_bytes()).hexdigest()
    assert asset['state'] == 'uploaded' and asset['digest'] == 'sha256:' + h
    print('ASSET_VERIFIED', leaf, flush=True)
release = api('PATCH', prefix + '/releases/' + str(release['id']), {
    'draft': False, 'prerelease': False, 'target_commitish': os.environ['GITHUB_SHA'],
    'body': notes, 'make_latest': 'false'})
print('RELEASE_PUBLISHED', release['html_url'], flush=True)
