{ pkgs, ... }:

{
  boot.tmpOnTmpfs = true;

  networking.hostName = "display";

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

  environment.systemPackages = with pkgs; [ surf unclutter ];

  environment.etc."i3.conf".text = ''
    exec surf "https://map.dvb.solutions"
    exec watch i3-msg "fullscreen enable global"
    exec unclutter
    exec xset -dpms
    exec setterm -blank 0 -powerdown 0
    exec xset s off
  '';

  services.xserver = {
    enable = true;
    displayManager = {
      gdm.enable = true;
      gdm.wayland = false;
      autoLogin = {
        enable = true;
        user = "display";
      };
    };
    desktopManager.xterm.enable = false;
    windowManager.i3 = {
      enable = true;
      configFile = "/etc/i3.conf";
    };
  };

  users.users."display" = {
    uid = 1000;
    isNormalUser = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}
