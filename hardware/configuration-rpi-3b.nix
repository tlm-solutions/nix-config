{ lib, pkgs, ... }:
{
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems = lib.mkForce [ "vfat" "ext4" ];
  };

  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;
}
