{ config, ... }: {
  services = {
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "map.${
          (builtins.replaceStrings [ "tlm.solutions" ] [ "dvb.solutions" ]
            config.deployment-TLMS.domain)
        }" = {
          enableACME = true;
          forceSSL = true;
          extraConfig = ''
            rewrite ^ https://kid.${config.deployment-TLMS.domain}/map/ permanent;
          '';
        };
        "map.${config.deployment-TLMS.domain}" = {
          enableACME = true;
          forceSSL = true;
          extraConfig = ''
            rewrite ^ https://kid.${config.deployment-TLMS.domain}/map/ permanent;
          '';
        };
      };
    };
  };
}
