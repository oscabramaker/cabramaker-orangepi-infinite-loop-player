#!/bin/bash
# Os cabramaker v1.0 — @oscabramaker
# Run inside the ARM root filesystem while preparing an offline image.
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends python3-gi python3-pil \
  gir1.2-gstreamer-1.0 gir1.2-gst-plugins-base-1.0 \
  gstreamer1.0-tools gstreamer1.0-plugins-base gstreamer1.0-plugins-good \
  gstreamer1.0-plugins-bad gstreamer1.0-libav device-tree-compiler openssh-server
id kiosk >/dev/null 2>&1 || useradd -m -s /usr/sbin/nologin kiosk
usermod -aG video,audio,render kiosk
install -d /usr/local/lib/cabramaker /media/MIDIA /etc/systemd/logind.conf.d
install -m 755 /opt/cabramaker-src/player.py /opt/cabramaker-src/splash.py /usr/local/lib/cabramaker/
install -m 755 /opt/cabramaker-src/setup-ssh.sh /usr/local/lib/cabramaker/
install -m 644 /opt/cabramaker-src/*.service /etc/systemd/system/
install -d /boot/overlay-user
dtc -@ -I dts -O dtb -o /boot/overlay-user/cabramaker-reset.dtbo /opt/cabramaker-src/external-reset.dts
printf 'LABEL=MIDIA /media/MIDIA vfat ro,nofail,uid=%s,gid=%s,fmask=0133,dmask=0022,x-systemd.device-timeout=5s 0 0\n' \
  "$(id -u kiosk)" "$(id -g kiosk)" >> /etc/fstab
cat > /etc/systemd/logind.conf.d/90-cabramaker.conf <<'EOF'
[Login]
HandlePowerKey=reboot
HandlePowerKeyLongPress=reboot
EOF
python3 - <<'PY'
from pathlib import Path
path = Path('/boot/armbianEnv.txt')
values = dict(line.split('=', 1) for line in path.read_text().splitlines()
              if '=' in line and not line.lstrip().startswith('#'))
values.update(verbosity='0', console='serial', bootlogo='false', disp_mode='1280x720p60', user_overlays='cabramaker-reset',
              extraargs='video=HDMI-A-1:1280x720@60D quiet systemd.show_status=false vt.global_cursor_default=0')
path.write_text(''.join(f'{key}={value}\n' for key, value in values.items()))
PY
systemctl enable cabramaker-video.service
systemctl enable cabramaker-ssh.service
systemctl set-default multi-user.target
systemctl mask getty@tty1.service armbian-resize-filesystem.service armbian-firstrun.service
# Initial account setup is unnecessary for a standalone appliance. Public
# images have no preset SSH password: SSH is disabled until explicitly set up.
rm -f /root/.not_logged_in_yet
passwd -l root
systemctl disable ssh.service 2>/dev/null || true
systemctl disable ssh.socket 2>/dev/null || true
install -d /etc/ssh/sshd_config.d
printf 'PermitRootLogin prohibit-password\nPasswordAuthentication no\n' > /etc/ssh/sshd_config.d/10-cabramaker.conf
rm -f /etc/ssh/ssh_host_* /var/lib/systemd/random-seed
rm -f /root/.bash_history /root/.zsh_history /root/.ssh/authorized_keys
truncate -s 0 /etc/machine-id
rm -f /var/lib/dbus/machine-id
echo cabramaker > /etc/hostname
sed -i 's/^127\.0\.1\.1.*/127.0.1.1 cabramaker/' /etc/hosts
install -d /etc/systemd/journald.conf.d
printf '[Journal]\nStorage=volatile\nRuntimeMaxUse=16M\n' > /etc/systemd/journald.conf.d/cabramaker.conf
apt-get clean
rm -rf /var/lib/apt/lists/*
