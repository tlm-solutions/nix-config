/*
  This file contains the configuration for the gnuradio sdr decoding pipeline
*/

{ pkgs, config, lib, ... }: {
  systemd = {
    services = {
      "data-accumulator" = {
        enable = true;
        wantedBy = [ "multi-user.target" ];

        script = ''
          exec ${pkgs.data-accumulator}/bin/data-accumulator --host 0.0.0.0 --port 8080&
        '';

        environment = {
          "PATH_FORMATTED_DATA" = "/var/lib/data-accumulator/formatted.csv";
          "PATH_RAW_DATA" = "/var/lib/data-accumulator/raw.csv";
        };
        serviceConfig = {
          Type = "forking";
          User = "data-accumulator";
          Restart = "always";
        };
      };
    };
  };

  # user accounts for systemd units
  users.users = {
    data-accumulator = {
      name = "data-accumulator";
      description = "";
      isNormalUser = true;
    };
  };
}
