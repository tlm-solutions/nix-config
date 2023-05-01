{ lib, ... }: {
  networking.useNetworkd = lib.mkForce true;
  systemd.network.enable = true;

  deployment-TLMS.net = {
    iface.uplink = {
      name = "enp1s0";
      mac = "96:00:02:25:d4:48";
      matchOn = "mac";
      useDHCP = true;
    };
  };
}
