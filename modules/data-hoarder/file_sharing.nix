{ config, ... }: {
  services = {
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
      "files.${(builtins.replaceStrings [ "tlm.solutions" ] [ "dvb.solutions" ] config.deployment-TLMS.domain)}" = {
        enableACME = true;
        forceSSL = true;
        extraConfig = ''
              rewrite ^ https://files.${config.deployment-TLMS.domain}$request_uri permanent;
        '';
      };
        "files.${config.deployment-TLMS.domain}" = {
          enableACME = true;
          forceSSL = true;
          root = "/var/lib/pub-files/";
          extraConfig = ''
            autoindex on;
          '';
        };
      };
    };
  };
}
