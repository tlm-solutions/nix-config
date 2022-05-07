{pkgs, lib, ...} : {
  services = {
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "files.dvb.solutions" = {
          enableACME = true;
          enableSSL = true;
          root = "/var/lib/data-accumulator/";
          extraConfig = ''
            autoindex on;
          '';
          };
        };
      };
    };
}
