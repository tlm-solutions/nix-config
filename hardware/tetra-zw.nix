{ config, lib, pkgs, ... }:

{
  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  imports = [
    ./disk-module
  ];
  networking = {
    interfaces.enp5s0.useDHCP = lib.mkDefault true;
    useDHCP = lib.mkDefault true;
  };

  networking.useNetworkd = true;
  networking.wireguard.enable = true;

  deployment-TLMS.net.iface.uplink = {
    name = lib.mkDefault "enp5s0";
    useDHCP = lib.mkDefault true;
  };

  boot.tmp.tmpfsSize = "25%";

  boot.kernelModules = [ "kvm-intel" "r8168" ];
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  boot.initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" "sd_mod" "sdhci_pci" "sdhci_acpi" ];
  boot.initrd.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  # some whoopsie in kernel 6.1.x maybe?
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_5_15;

  swapDevices = [ ];
  fileSystems."/" =
    {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
}
