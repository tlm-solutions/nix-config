{ pkgs, ... }:

{
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    autoOptimiseStore = true;
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
  };
  programs.mosh.enable = true;
}
