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
        locations."~ ^/(de|en)" = {
          root = if (config.deployment-TLMS.domain == "tlm.solutions") then "${pkgs.kindergarten}/bin/" else "${pkgs.kindergarten-staging}/bin/";
          index = "index.html";
          tryFiles = "$uri /$1/index.html?$args =404";
          extraConfig = ''
                      more_set_headers "Access-Control-Allow-Credentials: true";
            	    '';
        };
        extraConfig = ''
          map $http_accept_language $accept_language {
            ~*^de de;
            ~*^en en;
          }
          
          if ($accept_language ~ "^$") {
            set $accept_language "en";
          }
          
          rewrite ^/$ /$accept_language permanent;
        '';
      };
    };
  };
}
