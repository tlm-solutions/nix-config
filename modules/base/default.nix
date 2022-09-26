{ pkgs, config, self, lib, ... }:
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
      experimental-features = nix-command flakes
    '';
    autoOptimiseStore = true;
  };

  #networking.useNetworkd = true;

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
    (vim_configurable.override {
      guiSupport = false;
      luaSupport = false;
      perlSupport = false;
      pythonSupport = false;
      rubySupport = false;
      cscopeSupport = false;
      netbeansSupport = false;
    })
    wget
    git-crypt
    iftop
    tcpdump
    dig
    usbutils
    rtl-sdr
    hackrf
  ];

  networking.firewall.enable = lib.mkDefault true;
  networking.firewall.allowedTCPPorts = [ 22 ];
  users.users.root = {
    openssh.authorizedKeys.keyFiles = [
      "${self}/keys/ssh/revol-xut"
      "${self}/keys/ssh/oxa"
      "${self}/keys/ssh/oxa1"
      "${self}/keys/ssh/marenz1"
      "${self}/keys/ssh/marenz2"
      "${self}/keys/ssh/astro"
    ];
  };
  services.openssh = {
    enable = true;
    permitRootLogin = "prohibit-password";
    passwordAuthentication = false;
  };
  programs.mosh.enable = true;

  users.motd = if config.networking.hostName == "data-hoarder" then prodMotd else regMotd;

  dump-dvb.stopsJson = "${pkgs.stops}/stop/all.json";
  dump-dvb.graphJson = "${pkgs.stops}/graph/all.json";
}
