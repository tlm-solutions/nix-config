{ pkgs, config, ... }: {
  services = {
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "map.${config.deployment-dvb.domain}" = {
          forceSSL = true;
          enableACME = true;
          extraConfig = ''
            autoindex on;
          '';

          locations = let 
            nginx_config = ''
              # Permissions Policy - gps only
              add_header Permissions-Policy "geolocation=()";

              # Minimize information leaked to other domains
              add_header 'Referrer-Policy' 'origin-when-cross-origin';

              # Disable embedding as a frame
              add_header X-Frame-Options DENY;

              # Prevent injection of code in other mime types (XSS Attacks)
              add_header X-Content-Type-Options nosniff;

              # Enable XSS protection of the browser.
              # May be unnecessary when CSP is configured properly (see above)
              add_header X-XSS-Protection "1; mode=block";

              # STS
              add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
              add_header "Access-Control-Allow-Origin" "*";
            '';
          in {
            "/" = {
              root = if (config.deployment-dvb.domain == "dvb.solutions") then "${pkgs.windshield}/bin/" else "${pkgs.windshield-staging}/bin/";
              index = "index.html";

              tryFiles = "$uri /index.html =404";
            };
            "~ ^/stop/.*\.json$" = {
              root = "${pkgs.stops}/";
              extraConfig = nginx_config;
            };
            "~ ^/graph/.*\.json$" = {
              root = "${pkgs.stops}/";
              extraConfig = nginx_config;
            };
            "~ ^/region/.*\.json$" = {
              root = "${pkgs.stops}/";
              extraConfig = nginx_config;
            };
          };
        };
      };
    };
  };
}
