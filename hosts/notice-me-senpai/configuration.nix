{ self, pkgs, ... }: {
  sops.defaultSopsFile = self + /secrets/notice-me-senpai/secrets.yaml;

  networking.hostName = "notice-me-senpai";

  boot = {
    loader.grub = {
      device = "/dev/sda";
      configurationLimit = 3;
    };
    cleanTmpDir = true;
    kernelPackages = pkgs.linuxPackages_latest;
  };

  zramSwap.enable = true;
  virtualisation.vmware.guest.enable = true;

  boot.initrd.availableKernelModules =
    [ "ata_piix" "vmw_pvscsi" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/ac20e417-1e72-4054-b941-372b935a0cf7";
    fsType = "btrfs";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/e79a1405-fd1b-4caf-a43d-9ec7822c9307";
    fsType = "btrfs";
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/de512e60-4b1a-4b31-a28a-d2021fdec19a";
    fsType = "btrfs";
  };

  fileSystems."/tmp" = {
    device = "/dev/disk/by-uuid/39c75d79-4661-4d57-bb9e-9033a2ab3366";
    fsType = "xfs";
  };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/2b8ee579-0ef5-4a8c-87a2-c178a9403ebe"; }];

  system.stateVersion = "22.11";
}
