{ lib, config, self, registry, ... }:
let
  cfg = config.deployment-TLMS.monitoring;
  monitoring-host-registry = self.unevaluatedNixosConfigurations.notice-me-senpai.specialArgs.registry;
in
{
  options.deployment-TLMS.monitoring = with lib; {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to enable TLMS default prometheus exporter and log collection
      '';
    };
    node-exporter = with lib; {
      port = mkOption {
        type = types.port;
        default = 8119;
        description = ''
          Default port for prometheus node exporter to listen to
        '';
      };
    };
  };

  config =
    let
      wg-addr-pred = lib.assertMsg (registry ? wgAddr4) "to add system to monitoring, add it to TLMS wireguard first!";
    in
    lib.mkIf (cfg.enable && wg-addr-pred) {
      # prometheus node exporter
      services.prometheus.exporters = {
        node = {
          enable = true;
          port = cfg.node-exporter.port;
          listenAddress = registry.wgAddr4;
          enabledCollectors = [
            "systemd"
          ];
        };
      };

      # systemd journal log exporter
      services.fluent-bit = {
        enable = true;

        settings = {
          service = {
            flush = 1;
            log_level = "info";
          };

          pipeline = {
            inputs = [
              {
                name = "systemd";
                tag = "journal";
                db = "/var/lib/fluent-bit/journal.db";
              }
            ];

            outputs = [
              {
                name = "loki";
                match = "journal";

                host = monitoring-host-registry.wgAddr4;
                port = toString monitoring-host-registry.port-loki;
                uri = "/loki/api/v1/push";

                labels = "job=systemd-journal, host=${config.networking.hostName}, unit=$['_SYSTEMD_UNIT']";
              }
            ];
          };
        };
      };

      # Allow Fluent Bit to read the systemd journal.
      systemd.services.fluent-bit.serviceConfig.SupplementaryGroups = [
        "systemd-journal"
      ];
    };
}
