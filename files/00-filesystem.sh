#!/bin/bash

set -euo pipefail

# partitions
dd if=/dev/zero of=/dev/sda bs=100MiB count=1 status=none
xargs -L1 parted --script /dev/sda -- <<EOF
mklabel gpt
mkpart primary linux-swap 1MiB 100MiB
mkpart primary btrfs 100MiB 100%
set 1 bios_grub on
EOF

# filesystems
mkswap -L SWAP /dev/sda1
swapon /dev/sda1
mkfs.btrfs -L ROOT /dev/sda2
mount -t btrfs /dev/sda2 /mnt
