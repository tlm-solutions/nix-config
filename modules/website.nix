{ pkgs, lib, ... }: {
  services.nginx = {
    enable = true;
    virtualHosts = {
      "dvb.solutions" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          extraConfig = ''
            return 307 https://github.com/dump-dvb;
          '';
        };
      };
    };
  };
}

