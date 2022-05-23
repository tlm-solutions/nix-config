{ pkgs, lib, config, ... }: {
  services.nginx = {
    enable = true;
    virtualHosts = {
      "${config.dvb-dump.domain}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          extraConfig = ''
            return 307 https://docs.dvb.de;
          '';
        };
      };
    };
  };
}

