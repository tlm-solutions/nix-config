{ pkgs, config, ... }:

{
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    autoOptimiseStore = true;
    binaryCaches = [
      "https://dump-dvb.cachix.org"
    ];
    binaryCachePublicKeys = [
      "dump-dvb.cachix.org-1:+Dq7gqpQG4YlLA2X3xJsG1v3BrlUGGpVtUKWk0dTyUU="
    ];
  };

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "uk";
  };

  users.users.root = {
    openssh.authorizedKeys.keyFiles = [
      ../keys/ssh/revol-xut
      ../keys/ssh/oxa
      ../keys/ssh/oxa1
      ../keys/ssh/marenz1
      ../keys/ssh/marenz2
      ../keys/ssh/astro
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    htop
    tmux
    vim_configurable
    wget
    git-crypt
    iftop
  ];

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
  };
  programs.mosh.enable = true;
}
