{ config, ... }: {
  services = {
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "files.${config.deployment-dvb.domain}" = {
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
