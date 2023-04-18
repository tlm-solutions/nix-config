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
              rewrite ^ https://$subdomain.${config.deployemnt-TLMS.domain}$request_uri permanent;
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

