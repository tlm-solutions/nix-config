{ pkgs, config, lib, ... }: {
  services = {
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "map.dvb.solutions" = {
          enableACME = true;
          locations = {
            "/" = {
              index = "${pkgs.windshield}/index.html";
            };
          };
        };
      };
    };
  };
}
