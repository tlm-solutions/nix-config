{ config, ... }: {
  services.nginx = {
    enable = true;
    virtualHosts = {
      "${(builtins.replaceStrings [ "tlm.solutions" ] [ "dvb.solutions" ] config.deployment-TLMS.domain)}" = {
        enableACME = true;
        forceSSL = true;
        extraConfig = ''
          rewrite ^ https://kid.${config.deployment-TLMS.domain}/ permanent;
        '';
      };
      "${config.deployment-TLMS.domain}" = {
        enableACME = true;
        forceSSL = true;
        extraConfig = ''
          rewrite https://kid.${config.deployment-TLMS.domain}/ permanent;
        '';
      };
    };
  };
}

