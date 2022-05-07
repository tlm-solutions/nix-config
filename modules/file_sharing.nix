{pkgs, lib, ...} : {
  services = {
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "files.dvb.solutions" = {
          enableACME = true;
          onlySSL = true;
          root = "/var/lib/data-accumulator/";
          extraConfig = ''
            autoindex on;
          '';
          };
        };
      };
    };
}
