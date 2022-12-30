{ config, lib, TLMS, ... }:

{
  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  imports = [
    TLMS.nixosModules.disk-module
  ];
  networking = {
    interfaces.enp1s0.useDHCP = lib.mkDefault true;
    useDHCP = lib.mkDefault true;
  };

  networking.useNetworkd = true;
  networking.wireguard.enable = true;

  deployment-TLMS.net.iface.uplink = {
    name = lib.mkDefault "enp1s0";
    useDHCP = lib.mkDefault true;
  };

  boot.tmpOnTmpfsSize = "25%";

  boot.kernelModules = [ "kvm-intel" ];
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 1;
  boot.initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" "sd_mod" "sdhci_pci" "sdhci_acpi" ];
  boot.initrd.kernelModules = [ ];
  boot.extraModulePackages = [ ];

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
}
