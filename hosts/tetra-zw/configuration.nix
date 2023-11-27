{ self, pkgs, config, registry, ... }:

{
  imports = [
    "${self}/hardware/dell-wyse-3040.nix"
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
    };
  };

  services.resolved.dnssec = "false";

  system.stateVersion = "23.05";
}
