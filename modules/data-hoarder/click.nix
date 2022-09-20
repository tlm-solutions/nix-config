{ pkgs, config, ... }: {
  services.nginx = {
    enable = true;
    virtualHosts."click.${config.dump-dvb.domain}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        root = "${pkgs.click}/web/";
        index = "index.html";
        tryFiles = "$uri /index.html";
      };
      locations."/regions/" = {
        alias = "/${pkgs.click}/web/";
      };
      locations."/stations/" = {
        alias = "/${pkgs.click}/web/";
      };
      locations."/public/" = {
        alias = "/${pkgs.click}/web/";
      };
    };
  };
}
