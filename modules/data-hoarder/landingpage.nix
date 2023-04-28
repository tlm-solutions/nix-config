{ pkgs, config, ... }: {
  services = {
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "${(builtins.replaceStrings [ "tlm.solutions" ] [ "dvb.solutions" ] config.deployment-TLMS.domain)}" = {
          enableACME = true;
          forceSSL = true;
          extraConfig = ''
            rewrite ^ https://kid.${config.deployment-TLMS.domain}/en/map/ temporary;
          '';
        };
      };
    };
  };
}
