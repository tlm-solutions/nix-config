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
      "docs.${(builtins.replaceStrings [ "tlm.solutions" ] [ "dvb.solutions" ] config.deployment-TLMS.domain)}" = {
        enableACME = true;
        forceSSL = true;
        extraConfig = ''
              rewrite ^ https://docs.${config.deployment-TLMS.domain}$request_uri permanent;
        '';
      };
        "docs.${config.deployment-TLMS.domain}" = {
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
