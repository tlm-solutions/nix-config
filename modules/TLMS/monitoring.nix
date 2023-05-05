{ lib, config, ... }:
let
  cfg = config.deployment-TLMS.monitoring;
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
      wg-addr-pred = lib.assertMsg (!(isNull config.deployment-TLMS.net.wg.addr4)) "to add system to monitoring, add it to TLMS wireguard first!";
    in
      lib.mkIf (cfg.enable && wg-addr-pred) {
      # prometheus node exporter
      services.prometheus.exporters = {
        node = {
          enable = true;
          port = cfg.node-exporter.port;
          listenAddress = config.deployment-TLMS.net.wg.addr4;
          enabledCollectors = [
            "systemd"
          ];
        };
      };
    };
}
