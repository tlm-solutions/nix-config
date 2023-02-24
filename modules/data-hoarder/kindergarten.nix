{ pkgs, config, ... }: {
  services.nginx = {
    enable = true;
    virtualHosts."kid.${config.deployment-TLMS.domain}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        root = if (config.deployment-TLMS.domain == "dvb.solutions") then "${pkgs.kindergarten}/bin/" else "${pkgs.kindergarten-staging}/bin/";
        index = "index.html";
        tryFiles = "$uri /index.html =404";
      };
    };
  };
}
