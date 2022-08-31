{ config, lib, ... }:

{
  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.

  networking = if config.dump-dvb.systemNumber != 4 then {
    interfaces.enp1s0.useDHCP = true;
    useDHCP = false;
  } else {
    useDHCP = false;
    defaultGateway = "141.30.30.129";
    nameservers = [ "141.30.1.1" ];
    interfaces.enp1s0 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "141.30.30.149";
          prefixLength = 25;
        }
      ];
    };
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
