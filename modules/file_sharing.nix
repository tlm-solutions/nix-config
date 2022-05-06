{pkgs, lib, ...} : {
  services = {
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "files.dvb.solutions" = {
          enableACME = true;
          locations = {
            "/" = {
              root = "/var/lib/data-accumulator/";
            };
          };
        };
      };
    };
  };
}
