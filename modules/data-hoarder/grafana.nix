{ config, lib, self, ... }: {

  services = {
    # metrics collector
    prometheus = {
      enable = true;
      port = 9501;
      retentionTime = "2d";
      exporters = {
        # node exports hardware information like memory, cpu usage and the like
        node = {
          enable = true;
          enabledCollectors = [ "systemd" ];
          port = 9502;
        };

        # used for pinging services and checking their health
        blackbox = {
          enable = true;
          configFile = ../../services/blackbox.yaml;
        };
      };

      scrapeConfigs = [
        # hardware information
        {
          job_name = "data-hoarder hardware";
          static_configs = [{
            targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
          }];
        }

        # funnel connection metrics
        {
          job_name = "funnel-connections";
          static_configs = [
            {
              targets = [ "127.0.0.1:${toString config.dump-dvb.funnel.metrics.port}"];
            }
          ];
        }

        # checks if the data-accumulator server is running
        {
          job_name = "blackbox-data-accumulator";
          metrics_path = "/probe";
          params = { module = [ "http_2xx" ]; };
          static_configs = [{
            targets = [
              "127.0.0.1:8080"
            ];
          }];
          relabel_configs = [
            { source_labels = [ "__address__" ]; target_label = "__param_target"; }
            { source_labels = [ "__param_target" ]; target_label = "instance"; }
            { target_label = "__address__"; replacement = "127.0.0.1:9115"; }
          ];
        }

        # checks if the dvb-api server is running
        {
          job_name = "blackbox-dvb-api";
          metrics_path = "/probe";
          params = { module = [ "http_2xx" ]; };
          static_configs = [{
            targets = [
              "api.${config.deployment-dvb.domain}"
            ];
          }];
          relabel_configs = [
            { source_labels = [ "__address__" ]; target_label = "__param_target"; }
            { source_labels = [ "__param_target" ]; target_label = "instance"; }
            { target_label = "__address__"; replacement = "127.0.0.1:9115"; }
          ];
        }

      ];
    };
    promtail = {
      enable = true;
      # doesn't have a configFile option so this has to do
      configuration = builtins.fromJSON (lib.readFile "${self}/services/promtail.json");
    };


    # exports systemd logs and other
    loki = {
      enable = true;
      configFile = self + /services/loki.yaml;
    };

    # visualizer
    grafana = {
      settings.server = {
        domain = "monitoring.${config.deployment-dvb.domain}";
        http_port = 2342;
        http_addr = "127.0.0.1";
      };
      enable = true;
    };

    # reverse proxy for grafana
    nginx = {
      enable = true;
      virtualHosts = {
        "${toString config.services.grafana.settings.server.domain}" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = let 
            cfg = config.services.grafana;
          in {
            proxyPass = "http://${cfg.settings.server.http_addr}:${toString cfg.settings.server.http_port}";
            proxyWebsockets = true;
          };
        };
      };
    };
  };

  # noXlibs breaks pango/cairo
  environment.noXlibs = false;
}
