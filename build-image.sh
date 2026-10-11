#!/bin/bash
# Os cabramaker v1.0 — @oscabramaker
# Offline builder. This script works only on image FILES, never physical SDs.
# Linux x86_64, root, ARM binfmt emulation configured, 16 GB free disk space.
set -euo pipefail
[[ $EUID == 0 ]] || { echo 'Execute como root no Linux.' >&2; exit 1; }
[[ $# == 2 ]] || { echo 'Uso: build-image.sh BASE.img.xz SAIDA.img' >&2; exit 1; }
base=$(realpath "$1")
output=$(realpath -m "$2")
project=$(cd -- "$(dirname -- "$0")" && pwd)
[[ -f $base && ! -e $output && $output == *.img ]] || {
  echo 'A base deve ser um arquivo; a saída .img não pode existir.' >&2; exit 1;
}
[[ $(sha256sum "$base" | cut -d' ' -f1) == 7babe415b7e55e0554572af24d0177d1f69b41388d0f3ab11357abbcd790a1a6 ]] || {
  echo 'Checksum da imagem base diferente do esperado.' >&2; exit 1;
}
for tool in xz losetup sfdisk partx e2fsck resize2fs mkfs.vfat mount chroot python3; do
  command -v "$tool" >/dev/null || { echo "Ferramenta ausente: $tool"; exit 1; }
done
work=$(mktemp -d)
disk=''
cleanup() {
  mountpoint -q "$work/root/sys" && umount "$work/root/sys" || true
  mountpoint -q "$work/root/proc" && umount "$work/root/proc" || true
  mountpoint -q "$work/root/dev" && umount "$work/root/dev" || true
  mountpoint -q "$work/root/media/MIDIA" && umount "$work/root/media/MIDIA" || true
  mountpoint -q "$work/root" && umount "$work/root" || true
  [[ -z $disk ]] || losetup -d "$disk"
  rmdir "$work/root" "$work" 2>/dev/null || true
}
trap cleanup EXIT
xz -dc "$base" > "$output"
truncate -s 7516192768 "$output"
disk=$(losetup --find --show --partscan "$output")
printf 'label: dos\nlabel-id: 0xa980e54c\nunit: sectors\n\nstart=8192,size=6283264,type=83\nstart=6291456,size=8388608,type=c\n' | sfdisk "$disk"
partx -u "$disk"
sleep 2
e2fsck -f -p "${disk}p1" || [[ $? == 1 ]]
resize2fs "${disk}p1"
mkfs.vfat -F 32 -n MIDIA "${disk}p2"
mkdir "$work/root"
mount "${disk}p1" "$work/root"
mkdir -p "$work/root/media/MIDIA" "$work/root/opt/cabramaker-src"
mount "${disk}p2" "$work/root/media/MIDIA"
cp "$project"/src/* "$work/root/opt/cabramaker-src/"
cp -a "$project"/MIDIA/. "$work/root/media/MIDIA/"
mkdir -p "$work/root/media/MIDIA/videos"
mount --bind /dev "$work/root/dev"
mount -t proc proc "$work/root/proc"
mount -t sysfs sysfs "$work/root/sys"
cp -L /etc/resolv.conf "$work/root/etc/resolv.conf"
printf '#!/bin/sh\nexit 101\n' > "$work/root/usr/sbin/policy-rc.d"
chmod +x "$work/root/usr/sbin/policy-rc.d"
chroot "$work/root" /bin/bash /opt/cabramaker-src/install.sh
chroot "$work/root" dpkg-query -W -f='${Package}\t${Version}\t${Architecture}\n' > "$output.packages.tsv"
rm -f "$work/root/usr/sbin/policy-rc.d"
sync
cleanup
disk=''
trap - EXIT
xz -T0 -3 -k "$output"
sha256sum "$output" "$output.xz" > "$output.sha256"
echo "Imagem gerada: $output.xz. Teste em outra placa/cartão antes de publicar."
