{ pkgs, config, lib, ... }: {
  services = {
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "map.dvb.solutions" = {
          forceSSL = true;
          enableACME = true;
          locations = {
            "/" = {
              root = "${pkgs.windshield}/bin/";
              index = "index.html";
            };
          };
        };
      };
    };
  };
}
