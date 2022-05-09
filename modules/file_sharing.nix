{ pkgs, lib, ... }: {
  services = {
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "files.dvb.solutions" = {
          enableACME = true;
          onlySSL = true;
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
