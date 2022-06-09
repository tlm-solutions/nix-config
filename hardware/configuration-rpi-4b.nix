{ config, lib, pkgs, ... }:

{
  imports = [
  ];

  boot = {
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = lib.mkDefault true;
      raspberryPi = {
        enable = true;
        version = 4;
        uboot.enable = true;
        firmwareConfig = ''
          gpu_mem=192
          dtparam=audio=on
        '';
      };
    };
    kernelPackages = pkgs.linuxPackages_latest;
    # No ZFS on latest kernel:
    supportedFilesystems = lib.mkForce [ "vfat" "ext4" ];
  };

  sdImage = {
    compressImage = false;
    imageBaseName = config.networking.hostName;
    firmwareSize = 512;
  };

  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;
}
