{ config, lib, pkgs, ... }:

{
  boot.initrd.availableKernelModules = [ "usbhid" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };

  fileSystems."/boot/firmware" = {
    device = "/dev/disk/by-label/FIRMWARE";
    fsType = "vfat";
  };

  swapDevices = [ ];

  hardware.enableRedistributableFirmware = true;
  hardware.deviceTree.enable = false;
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
}
