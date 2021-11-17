#!/bin/bash

# required env:
# - ARCH_RELEASE
# - KEYMAP
# - LOCALE
# - TIMEZONE
#
# optional env
# - EXTRA_SERVICES

set -euo pipefail

# prepare mounts
readonly iso='/root/root.x86_64'

"${iso}/bin/arch-chroot" /mnt <<EOF
set -euo pipefail
systemctl enable systemd-timesyncd systemd-networkd systemd-resolved sshd qemu-guest-agent cloud-init cloud-final ${EXTRA_SERVICES}
ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
hwclock --systohc
echo 'KEYMAP=${KEYMAP}' > /etc/vconsole.conf
echo '${LOCALE} UTF-8' > /etc/locale.gen
echo 'LANG=${LOCALE}' > /etc/locale.conf
locale-gen
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg /dev/sda
mkinitcpio -P
systemctl set-default multi-user.target
hostnamectl hostname archlinux
EOF
