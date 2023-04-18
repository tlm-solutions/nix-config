{ pkgs, config, ... }: {
  services.nginx = {
    enable = true;
    virtualHosts = {
      "kid.${(builtins.replaceStrings [ "tlm.solutions" ] [ "dvb.solutions" ] config.deployment-TLMS.domain)}" = {
        enableACME = true;
        forceSSL = true;
        extraConfig = ''
          rewrite ^ https://kid.${config.deployment-TLMS.domain}$request_uri permanent;
        '';
      };
      "kid.${config.deployment-TLMS.domain}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          root = if (config.deployment-TLMS.domain == "tlm.solutions") then "${pkgs.kindergarten}/bin/" else "${pkgs.kindergarten-staging}/bin/";
          index = "index.html";
          tryFiles = "$uri /index.html =404";
          extraConfig = ''
                      more_set_headers "Access-Control-Allow-Credentials: true";
            	    '';
        };
      };
    };
  };
}
