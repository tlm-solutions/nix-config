{ config, ... }: {
  services.nginx = {
    enable = true;
    virtualHosts = {
      "${(builtins.replaceStrings [ "tlm.solutions" ] [ "dvb.solutions" ] config.deployment-TLMS.domain)}" = {
        enableACME = true;
        forceSSL = true;
        extraConfig = ''
          rewrite ^ https://map.${config.deployment-TLMS.domain}$request_uri permanent;
        '';
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

