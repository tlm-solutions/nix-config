{ pkgs, lib, ... }: {
  services = {
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "docs.dvb.solutions" = {
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
