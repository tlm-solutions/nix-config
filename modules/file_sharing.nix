{ pkgs, lib, config, ... }: {
  services = {
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "files.${config.dvb-dump.domain}" = {
          enableACME = true;
          forceSSL = true;
          root = "/var/lib/data-accumulator/";
          extraConfig = ''
            autoindex on;
          '';
        };
      };
    };
    cron = {
      enable = true;
      systemCronJobs = [
        "0 0 0 * * cd /var/lib/data-accumulator/ && cp ./formatted.csv ./data/$(date +\"%d-%m-%Y\")-raw-data.csv"
      ];

    };
  };
}
