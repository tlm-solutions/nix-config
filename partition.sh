parted /dev/mmcblk0 -- mklabel gpt
parted /dev/mmcblk0 -- mkpart ESP fat32 1MiB 256MiB
parted /dev/mmcblk0 -- set 1 esp on
parted /dev/mmcblk0 -- mkpart primary 256MiB

mkfs.fat -F 32 -n boot /dev/mmcblk0p1
mkfs.ext4 -L nixos /dev/mmcblk0p2

mount /dev/disk/by-label/root /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot

cd /etc/nixos/
rm /etc/nixos/*
git init
git remote add origin https://github.com/dump-dvb/nix-config.git
git pull
