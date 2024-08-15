{ self, lib, pkgs, config, registry, ... }:

{
  imports = [
    "${self}/hardware/tetra-zw.nix"
  ];

  boot.tmp.useTmpfs = true;

  # reboot 60 seconds after kernel panic
  boot.kernel.sysctl."kernel.panic" = 60;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  nix = {
    settings.build-cores = 1;
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-old";
    };
  };

  services.resolved.dnssec = "false";

  system.stateVersion = "23.11";

  deployment-TLMS.monitoring.enable = registry.monitoring;

  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "ondemand";
}
