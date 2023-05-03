{ self, config, ... }:
{
  # metrics exporter
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

  # log exporter

}
