{ pkgs, config, ... }: {
  services.nginx = {
    enable = true;
    virtualHosts."click.${config.deployment-TLMS.domain}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        root = if (config.deployment-TLMS.domain == "dvb.solutions") then "${pkgs.click}/web/" else "${pkgs.click-staging}/web/";
        index = "index.html";
        tryFiles = "$uri /index.html";
      };
      locations."/regions/" = {
        alias = "/${pkgs.click}/web/";
      };
      locations."/stations/" = {
        alias = "/${pkgs.click}/web/";
      };
      locations."/mystations/" = {
        alias = "/${pkgs.click}/web/";
      };
    };
  };
}
