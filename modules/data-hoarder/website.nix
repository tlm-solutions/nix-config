{ config, ... }: {
  services.nginx = {
    enable = true;
    virtualHosts = {
      "${config.ddvbDeployment.domain}" = {
        enableACME = true;
        forceSSL = true;
        locations = {
          "/" = {
            extraConfig = ''
              return 307 https://docs.dvb.solutions;
            '';
          };
        };
      };
    };
  };
}

