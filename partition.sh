
parted /dev/mmcblk -- mklabel gpt
parted /dev/mmcblk -- mkpart ESP fat32 1MiB 512MiB
parted /dev/mmcblk -- set 3 esp on
parted /dev/mmcblk -- mkpart primary 512MiB.

mkfs.fat -F 32 -n boot /dev/mmcblk1
mkfs.ext4 -L root /dev/mmcblk2

mount /dev/disk/by-label/root /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot

cd /etc/nixos/
git init
git remote add origin https://github.com/dump-dvb/nix-config.git
git pull


