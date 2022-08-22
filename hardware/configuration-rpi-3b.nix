{ lib, pkgs, ... }:
{
  imports = [
  ];

  boot = {
    loader = {
      grub.enable = false;
      raspberryPi = {
        enable = true;
        version = 4;
      };
    };
    kernelPackages = pkgs.linuxPackages_latest;
    # No ZFS on latest kernel:
    supportedFilesystems = lib.mkForce [ "vfat" "ext4" ];
  };

  # sdImage = {
  #   compressImage = false;
  #   imageBaseName = config.networking.hostName;
  #   firmwareSize = 512;
  # };

  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;
}
