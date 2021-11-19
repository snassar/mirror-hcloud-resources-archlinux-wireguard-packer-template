#!/bin/bash

# required env:
# - ARCH_RELEASE
# - KEYMAP
# - LOCALE
# - TIMEZONE
#
# optional env
# - EXTRA_PACKAGES

set -euo pipefail

readonly ARCH_MIRROR='https://mirror.hetzner.de/archlinux'
readonly ARCH_ISO="archlinux-bootstrap-${ARCH_RELEASE//-/.}-x86_64.tar.gz"

# obtain arch tools
curl --fail -o "${ARCH_ISO}"     "${ARCH_MIRROR}/iso/${ARCH_RELEASE//-/.}/${ARCH_ISO}"
tar xzf "./${ARCH_ISO}"
rm "./${ARCH_ISO}" # save ramfs memory

# prepare mounts
readonly iso='/root/root.x86_64'
mount --bind "$iso" "$iso" # XXX arch-chroot needs / to be a mountpoint
mount --bind /mnt "$iso/mnt"

# install base
"${iso}/bin/arch-chroot" "$iso" <<EOF
set -euo pipefail
echo 'Server = ${ARCH_MIRROR}/\$repo/os/\$arch' > /etc/pacman.d/mirrorlist
pacman-key --init
pacman-key --populate archlinux
pacstrap -d /mnt base linux linux-firmware cloud-guest-utils cloud-init openssh os-prober qemu-guest-agent sudo systemd-resolvconf grub btrfs-progs iptables-nft wireguard-tools ${EXTRA_PACKAGES}
genfstab -U /mnt > /mnt/etc/fstab
echo 'proc /proc proc defaults,hidepid=2 0 0' >> /mnt/etc/fstab
EOF
