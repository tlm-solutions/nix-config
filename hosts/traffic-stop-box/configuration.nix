{ config, ... }:

{
  boot.tmpOnTmpfs = true;

  networking.hostName = "traffic-stop-box-${toString config.deployment-dvb.systemNumber}"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  documentation.enable = false;
  documentation.nixos.enable = false;

  nix = {
    buildCores = 1;
    gc = {
      automatic = true;
      dates = "daily";
    };
  };

  services.journald.extraConfig = ''
    SystemMaxUse=5M
  '';

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}
