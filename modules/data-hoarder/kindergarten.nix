{ pkgs, config, ... }: {
  services.nginx = {
    enable = true;
    virtualHosts = {
      "kid.${
        (builtins.replaceStrings [ "tlm.solutions" ] [ "dvb.solutions" ]
          config.deployment-TLMS.domain)
      }" = {
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
          root = "${pkgs.kindergarten.override {inherit (config.deployment-TLMS ) domain; }}";
          tryFiles = "$uri /$1/index.html =404";
        };
        locations."~ ^/(?!en|de)" = {
          extraConfig = ''
            rewrite ^ /en$request_uri last;
          '';
        };
        extraConfig = ''
          if ($accept_language ~ "^$") {
            set $accept_language "en";
          }

          rewrite ^/$ /$accept_language last;
        '';
      };
    };
    commonHttpConfig = ''
      map $http_accept_language $accept_language {
          ~*^de de;
          ~*^en en;
      }
    '';
  };
}
