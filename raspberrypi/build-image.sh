#!/bin/bash
# Os cabramaker Raspberry Pi 1.0 — @oscabramaker. Image FILES only.
set -euo pipefail
[[ $EUID == 0 && $# == 2 ]] || { echo 'Uso (Linux root): build-image.sh BASE.img.xz SAIDA.img'; exit 1; }
base=$(realpath "$1"); output=$(realpath -m "$2")
project=$(cd -- "$(dirname -- "$0")" && pwd)
[[ -f $base && ! -e $output && $output == *.img ]] || exit 1
echo '483db18a48da399b5b7022ffae9a07bc6d99daab30e593aedac09b69ff422843  '"$base" | sha256sum -c -
for tool in xz losetup sfdisk e2fsck resize2fs mkfs.vfat mount chroot python3 zip dd; do command -v "$tool" >/dev/null; done
work=$(mktemp -d); disk=''; source_disk=''
cleanup() {
 for p in sys proc dev media/MIDIA boot/firmware ''; do
  mountpoint -q "$work/root/$p" && umount "$work/root/$p" || true
 done
 mountpoint -q "$work/base-boot" && umount "$work/base-boot" || true
 [[ -z $disk ]] || losetup -d "$disk"
 [[ -z $source_disk ]] || losetup -d "$source_disk"
 [[ ! -f $work/base.img ]] || rm -f "$work/base.img"
 rmdir "$work/root" "$work/base-boot" "$work" 2>/dev/null || true
}
trap cleanup EXIT
xz -dc "$base" > "$work/base.img"
source_disk=$(losetup --find --show --partscan --read-only "$work/base.img")
truncate -s 7516192768 "$output"
disk=$(losetup --find --show --partscan "$output")
printf 'label: dos\nlabel-id: 0x43414233\nunit: sectors\n\nstart=16384,size=7323648,type=c\nstart=7340032,size=7340032,type=83\n' | sfdisk "$disk"
command -v udevadm >/dev/null && udevadm settle || true
command -v mdev >/dev/null && mdev -s || true
dd if="${source_disk}p2" of="${disk}p2" bs=4M conv=fsync status=progress
e2fsck -fp "${disk}p2" || [[ $? == 1 ]]
resize2fs "${disk}p2"
mkfs.vfat -F 32 -n MIDIA "${disk}p1"
mkdir "$work/root" "$work/base-boot"
mount "${disk}p2" "$work/root"
mkdir -p "$work/root/boot/firmware" "$work/root/media/MIDIA" "$work/root/opt/cabramaker-src"
mount "${disk}p1" "$work/root/boot/firmware"
mount -o ro "${source_disk}p1" "$work/base-boot"
cp -a "$work/base-boot/." "$work/root/boot/firmware/"
cp -a "$project/MIDIA/." "$work/root/boot/firmware/"
mount -o bind,ro "$work/root/boot/firmware" "$work/root/media/MIDIA"
for source in "$project"/src/*; do
 [[ -f $source ]] && cp "$source" "$work/root/opt/cabramaker-src/"
done
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
cleanup; disk=''; source_disk=''; trap - EXIT
zip -j -1 "$output.zip" "$output"
sha256sum "$output" "$output.zip" > "$output.sha256"
echo 'Imagem gerada. Confira integridade e teste em cada modelo antes de distribuir outra build.'
