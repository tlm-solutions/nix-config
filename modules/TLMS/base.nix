{ pkgs, config, lib, registry, ... }:
let
  regMotd = ''
     _._     _,-'""`-._
    (,-.`._,'(       |\`-/|  Be vewy vewy quiet!
        `-.-' \ )-`( , o o)  We're hunting tewegwams!
              `-    \`_`"'-
  '';
  prodMotd = ''
             .-o=o-.  <===== THIS IS FUCKING PROD YOU PLAYIN' WITH
         ,  /=o=o=o=\ .--.
        _|\|=o=O=o=O=|    \
    __.'  a`\=o=o=o=(`\   /
    '.   a 4/`|.-""'`\ \ ;'`)   .---.
      \   .'  /   .--'  |_.'   / .-._)
       `)  _.'   /     /`-.__.' /
    jgs `'-.____;     /'-.___.-'
                 `"""`
  '';
in
{
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
    '';
    settings = {
      auto-optimise-store = true;
      experimental-features = "nix-command flakes";
    };
  };

  networking.useNetworkd = true;

  networking.hostName = registry.hostName;

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

  environment.systemPackages = with pkgs; [
    git
    htop
    tmux
    screen
    neovim
    wget
    git-crypt
    iftop
    tcpdump
    dig
    usbutils
    rtl-sdr
    hackrf
    ssh-to-age
    hwloc
    lshw
  ];

  networking.firewall.enable = lib.mkDefault true;

  networking.firewall.allowedTCPPorts = [ 22 ];
  users.users.root = {
    openssh.authorizedKeys.keyFiles = [
      ../../keys/ssh/revol-xut
      ../../keys/ssh/oxa
      ../../keys/ssh/oxa1
      ../../keys/ssh/marenz1
      ../../keys/ssh/marenz2
      ../../keys/ssh/marcel
    ];
  };
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };
  programs.mosh.enable = true;

  users.motd = if config.networking.hostName == "data-hoarder" then prodMotd else regMotd;

  # TODO: comment back in after 24.05 transtition
  # temporarily disable screen because of added enable option with assertion
  # programs.screen.enable = true;
  # programs.screen.screenrc = ''
  #   defscrollback 10000
  #
  #   startup_message off
  #
  #   hardstatus on
  #   hardstatus alwayslastline
  #   hardstatus string "%w"
  # '';
}
