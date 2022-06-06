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
      "https://nix-serve.hq.c3d2.de"
    ];
    binaryCachePublicKeys = [
      "dump-dvb.cachix.org-1:+Dq7gqpQG4YlLA2X3xJsG1v3BrlUGGpVtUKWk0dTyUU="
      "nix-serve.hq.c3d2.de:KZRGGnwOYzys6pxgM8jlur36RmkJQ/y8y62e52fj1ps="
    ];
  };

  # Select internationalisation properties.
  console = {
    font = "Lat2-Terminus16";
    keyMap = "uk";
  };

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "en_US/ISO-8859-1"
    "C.UTF-8/UTF-8"
  ];

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
    (vim_configurable.override { guiSupport = false; luaSupport = false; perlSupport = false; pythonSupport = false; rubySupport = false; cscopeSupport = false; netbeansSupport = false; })
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
