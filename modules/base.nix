{ pkgs, config, ... }:

{
  _module.args.buildVM = false;

  # use Nix 2.4 for flakes support
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
     '';
  };

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "uk";
  };

  users.users.root = {
    openssh.authorizedKeys.keyFiles = [
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    atop
    fish
    git
    htop
    tmux
    vim_configurable
    wget
    git-crypt
  ];

  users.users.root.password = "wtfwtf";

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;
  programs.mosh.enable = true;
}
