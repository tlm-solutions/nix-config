{ lib, ... }: {
  networking.firewall.allowedUDPPorts = [ 51820 ];
  networking.wireguard.enable = true;

  networking.useNetworkd = lib.mkForce true;
  systemd.network.enable = true;

  deployment-TLMS.net = {
    iface.uplink = {
      name = "ifacename";
      mac = "00:50:56:83:4e:9e";
      matchOn = "mac";
      useDHCP = false;
      addr4 = "172.26.121.158/23";
      dns = [ "141.30.1.1" "141.76.14.1" ];
      routes = [{
        routeConfig = {
          Gateway = "172.26.120.1";
          GatewayOnLink = true;
          Destination = "0.0.0.0/0";
        };
      }];
    };
  };
}
