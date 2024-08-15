{ config, lib, pkgs, ... }:

{
  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  imports = [
    ./disk-module
  ];
  networking = {
    interfaces.enp6s0.useDHCP = lib.mkDefault true;
    useDHCP = lib.mkDefault true;
  };

  networking.useNetworkd = true;
  networking.wireguard.enable = true;

  deployment-TLMS.net.iface.uplink = {
    name = lib.mkDefault "enp6s0";
    useDHCP = lib.mkDefault true;
  };

  boot.tmp.tmpfsSize = "25%";

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "nvme"
    "ehci_pci"
    "ahci"
    "uas"
    "usb_storage"
    "sd_mod"
    "sr_mod"
    "rtsx_pci_sdmmc"
    "aesni_intel"
    "cryptd"
    "essiv"
    "r8169"
  ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.kernelParams = [ "btusb.enable_autosuspend=n" ];
  boot.extraModulePackages = [ ];
  boot.supportedFilesystems = [ ];

  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_6;

  swapDevices = [ ];
  fileSystems."/" =
    {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
    };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 1;
}
