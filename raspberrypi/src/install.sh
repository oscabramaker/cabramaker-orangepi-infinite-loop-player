#!/bin/bash
# Os cabramaker 1.0 Raspberry Pi — @oscabramaker
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update
# Preserve the VLC build validated on the physical Pi; repositories may advance.
vlc_packages=$(mktemp -d)
export CABRAMAKER_VLC_PACKAGES="$vlc_packages"
python3 - <<'PY'
import hashlib,json,os,urllib.request
from pathlib import Path
out=Path(os.environ['CABRAMAKER_VLC_PACKAGES'])
for package in json.loads(Path('/opt/cabramaker-src/vlc-packages.json').read_text()):
    data=urllib.request.urlopen(package['url'],timeout=120).read()
    assert hashlib.sha256(data).hexdigest()==package['sha256'],package['filename']
    (out/package['filename']).write_bytes(data)
PY
apt-get install -y --no-install-recommends "$vlc_packages"/*.deb python3-pil openssh-server libpam-systemd avahi-daemon
apt-mark hold libvlc-bin libvlc5 libvlccore9 vlc-bin vlc-data vlc-plugin-base vlc-plugin-video-output
rm -rf "$vlc_packages"
id kiosk >/dev/null 2>&1 || useradd -m -s /usr/sbin/nologin kiosk
usermod -aG video,audio,render,tty kiosk
install -d /usr/local/lib/cabramaker /media/MIDIA /etc/systemd/logind.conf.d
install -m 755 /opt/cabramaker-src/{player.py,splash.py,setup-ssh.sh,salvar-status.sh} /usr/local/lib/cabramaker/
install -m 644 /opt/cabramaker-src/*.service /etc/systemd/system/
python3 - <<'PY'
from pathlib import Path
boot=Path('/boot/firmware')
config=boot/'config.txt'
s=config.read_text()
# Preserve the official firmware settings and scope appliance settings to all models.
s+='\n[all]\n# Os cabramaker Raspberry Pi 3 B / B+\ndisable_splash=1\ndisable_overscan=1\ngpu_mem=128\ndtoverlay=gpio-shutdown,gpio_pin=4,active_low=1,gpio_pull=up\n'
config.write_text(s)
p=boot/'cmdline.txt'
args=p.read_text().split()
args=[a for a in args if not a.startswith(('console=','init=','root=','systemd.run=','systemd.run_success_action=','systemd.run_failure_action=','systemd.unit=','video=','loglevel=','systemd.show_status=')) and a not in ('resize','firstboot','quiet')]
args+=['root=PARTUUID=43414233-02']
args+=['console=serial0,115200','console=tty1','quiet','loglevel=3','systemd.show_status=false',
       'vt.global_cursor_default=0','logo.nologo','video=HDMI-A-1:1280x720@60D']
p.write_text(' '.join(args)+'\n')
fstab=Path('/etc/fstab')
lines=[l for l in fstab.read_text().splitlines() if len(l.split()) < 2 or l.lstrip().startswith('#') or l.split()[1] not in ('/','/boot/firmware','/media/MIDIA')]
lines+=['PARTUUID=43414233-01 /boot/firmware vfat defaults 0 2',
        'PARTUUID=43414233-02 / ext4 defaults,noatime 0 1',
        '/boot/firmware /media/MIDIA none bind,ro,x-systemd.requires-mounts-for=/boot/firmware 0 0']
fstab.write_text('\n'.join(lines)+'\n')
PY
printf '[Login]\nHandlePowerKey=reboot\nHandlePowerKeyLongPress=reboot\n' > /etc/systemd/logind.conf.d/90-cabramaker.conf
systemctl enable cabramaker-video.service cabramaker-ssh.service cabramaker-status.service
systemctl set-default multi-user.target
systemctl mask getty@tty1.service userconfig.service userconfig-pi.service rpi-resize.service
install -d /etc/cloud
touch /etc/cloud/cloud-init.disabled
systemctl disable NetworkManager-wait-online.service 2>/dev/null || true
systemctl disable ssh.service ssh.socket 2>/dev/null || true
passwd -l root
install -d /etc/ssh/sshd_config.d
printf 'PermitRootLogin prohibit-password\nPasswordAuthentication no\n' > /etc/ssh/sshd_config.d/10-cabramaker.conf
rm -f /etc/ssh/ssh_host_* /var/lib/systemd/random-seed /root/.bash_history /root/.ssh/authorized_keys
truncate -s 0 /etc/machine-id
rm -f /var/lib/dbus/machine-id
echo cabramaker-pi > /etc/hostname
sed -i 's/^127\.0\.1\.1.*/127.0.1.1 cabramaker-pi/' /etc/hosts
install -d /etc/systemd/journald.conf.d
printf '[Journal]\nStorage=volatile\nRuntimeMaxUse=16M\n' > /etc/systemd/journald.conf.d/cabramaker.conf
apt-get clean
rm -rf /var/lib/apt/lists/*
