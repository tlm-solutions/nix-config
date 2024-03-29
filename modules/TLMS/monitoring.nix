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
    promtail-config = with lib; {
      http_port = mkOption {
        type = types.port;
        default = 28183;
        description = ''Default port for promtail log exporter'';
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

      # promtail log exporter
      services.promtail = {
        enable = true;
        configuration = {
          server = {
            http_listen_port = cfg.promtail-config.http_port;
            grpc_listen_port = 0;
          };
          positions = {
            filename = "/tmp/positions.yaml";
          };
          clients = [{
            url = "http://${monitoring-host-registry.wgAddr4}:${toString monitoring-host-registry.port-loki}/loki/api/v1/push";
          }];
          scrape_configs = [{
            job_name = "journal";
            journal = {
              max_age = "24h";
              labels = {
                job = "systemd-journal";
                host = config.networking.hostName;
              };
            };
            relabel_configs = [{
              source_labels = [ "__journal__systemd_unit" ];
              target_label = "unit";
            }];
          }];
        };
      };
    };
}
