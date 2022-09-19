{ pkgs, config, ... }: {
  services.nginx = {
    enable = true;
    virtualHosts."click.${config.dump-dvb.domain}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        root = "${pkgs.click}/web/";
        index = "index.html";
      };
      locations."/regions" = {
        alias = "/";
      };
      locations."/stations" = {
        alias = "/";
      };
      locations."/public" = {
        alias = "/";
      };
    };
  };
}
