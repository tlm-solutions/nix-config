{pkgs, lib, ...} : {
  services = {
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "files.dvb.solutions" = {
          enableACME = true;
          default = true;
          forceSSL = true;
          root = "/var/lib/data-accumulator/";
          extraConfig = ''
            autoindex on;
          '';
          };
        };
      };
    };
}
