{ config, ... }: {
  services.nginx = {
    enable = true;
    virtualHosts = {
      "~^(?<subdomain>\w+)\.dvb\.solutions$" = {
        enableACME = true;
        forceSSL = true;
        locations = {
          "/" = {
            extraConfig = ''
              rewrite ^ https://$subdomain.${config.deployment-TLMS.domain}$request_uri permanent;
            '';
          };
        };
      };
      "${config.deployment-TLMS.domain}" = {
        enableACME = true;
        forceSSL = true;
        locations = {
          "/" = {
            extraConfig = ''
              return 307 https://map.tlm.solutions;
            '';
          };
        };
      };
    };
  };
}

