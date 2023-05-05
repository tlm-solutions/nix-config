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
    monitoring.node-exporter = with lib; {
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
      wg-addr-pred = !isNull config.deployment-TLMS.net.wg.addr4;
      check-wg = enabled:
        lib.assertMsg (enabled && wg-addr-pred)
          ''For monitoring to be working the system must be in wireguard. See config.deplayment-TLMS.net.wg'';
    in
    lib.mkIf (check-wg cfg.enable) {
      # prometheus node exporter
      services.prometheus.exporters = {
        node = {
          enable = true;
          port = 8119;
          listenAddress = config.deployment-TLMS.net.wg.addr4;
          enabledCollectors = [
            "systemd"
          ];
        };
      };
    };
}
