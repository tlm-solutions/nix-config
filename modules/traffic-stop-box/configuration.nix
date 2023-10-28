{ pkgs, config, self, ... }:

{
  boot.tmp.useTmpfs = true;

  networking.hostName = "traffic-stop-box-${toString config.deployment-TLMS.systemNumber}"; # Define your hostname.

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

  system.stateVersion = "21.11"; # Did you read the comment?
}
