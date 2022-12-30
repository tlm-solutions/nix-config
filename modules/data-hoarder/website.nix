{ config, ... }: {
  services.nginx = {
    enable = true;
    virtualHosts = {
      "${config.deployment-TLMS.domain}" = {
        enableACME = true;
        forceSSL = true;
        locations = {
          "/" = {
            extraConfig = ''
              return 307 https://map.dvb.solutions;
            '';
          };
        };
      };
    };
  };
}

