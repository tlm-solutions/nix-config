{ pkgs, lib, config, ... }: {
  services = {
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "docs.${config.dvb-dump.domain}" = {
          enableACME = true;
          forceSSL = true;
          locations = {
            "/" = {
              root = "${pkgs.dvb-dump-docs}/bin/";
              index = "index.html";
            };
          };
        };
      };
    };
  };
}
