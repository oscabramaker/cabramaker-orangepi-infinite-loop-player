#!/bin/bash
# Os cabramaker v1.0 — @oscabramaker
# Optional access: copy ONLY your public key to MIDIA/ssh.pub.
set -euo pipefail
key=/media/MIDIA/ssh.pub
[ -f "$key" ] || exit 0
[ "$(stat -c %s "$key")" -le 16384 ] || exit 0
ssh-keygen -l -f "$key" >/dev/null
install -d -m 700 /root/.ssh
install -m 600 "$key" /root/.ssh/authorized_keys
ssh-keygen -A
install -d /etc/ssh/sshd_config.d
printf 'PermitRootLogin prohibit-password\nPasswordAuthentication no\n' > /etc/ssh/sshd_config.d/10-cabramaker.conf
# Start for this boot; the public key file controls activation on every boot.
systemctl --no-block start ssh.service
