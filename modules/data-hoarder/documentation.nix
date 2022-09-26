{ pkgs, config, ... }:
let
  documentation-package = pkgs.callPackage ../../pkgs/documentation.nix { };
in
{
  services = {
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "docs.${config.dump-dvb.domain}" = {
          enableACME = true;
          forceSSL = true;
          locations = {
            "/" = {
              root = "${documentation-package}/bin/";
              index = "index.html";
            };
          };
        };
      };
    };
  };
}
