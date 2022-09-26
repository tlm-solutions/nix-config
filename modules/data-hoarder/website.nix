{ config, ... }: {
  services.nginx = {
    enable = true;
    virtualHosts = {
      "${config.dump-dvb.domain}" = {
        enableACME = true;
        forceSSL = true;
        locations = {
          "/" = {
            extraConfig = ''
              add_header Access-Control-Allow-Origin *;
              return 307 https://docs.dvb.solutions;
            '';
          };
        };
      };
    };
  };
}

