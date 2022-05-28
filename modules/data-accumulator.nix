/*
  This file contains the configuration for the gnuradio sdr decoding pipeline
*/

{ pkgs, config, lib, ... }: {
  systemd = {
    services = {
      "data-accumulator" = {
        enable = true;
        requires = [ "influxdb.service" ];
        after = [ "influxdb.service" ];
        wantedBy = [ "multi-user.target" ];

        script = ''
          exec ${pkgs.data-accumulator}/bin/data-accumulator --host 0.0.0.0 --port 8080&
        '';

        environment = {
          "INFLUX_HOST" = "http://localhost:8086";
          "GRPC_HOST" = "http://127.0.0.1:50051";
        };
        serviceConfig = {
          Type = "forking";
          User = "data-accumulator";
          Restart = "always";
        };
      };
    };
  };

  services = {
    influxdb = {
      enable = true;
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
