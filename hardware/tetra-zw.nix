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

  # Enable OpenGL/OpenCL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
      rocmPackages.clr
      rocmPackages.rocminfo
      rocmPackages.rocm-runtime
      rocmPackages.rocm-smi
    ];
  };

  nixpkgs.config.allowUnfree = true;
  hardware.enableAllFirmware = true;

  hardware.amdgpu.opencl.enable = true;
  nixpkgs.config.rocmSupport = true;

  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];

  # Adjust power limits of the processor
  systemd.services."adjust-power-limits" = {
    enable = true;
    wantedBy = [ "multi-user.target" ];

    script = ''
      exec ${pkgs.ryzenadj}/bin/ryzenadj --stapm-limit=30000 --fast-limit=30000 --slow-limit=30000 --tctl-temp=100 --max-performance --apu-skin-temp=100 --skin-temp-limit=100
    '';

    serviceConfig = {
      Type = "oneshot";
      User = config.users.users.root.name;
    };
  };

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
