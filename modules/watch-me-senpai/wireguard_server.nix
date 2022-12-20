{ config, ... }:
let
  port = 51820;
  mac_addr =  "03:db:db:db:db:db";
in
{
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  networking.firewall.allowedUDPPorts = [ port ];

  deployment-dvb.net = {
    /*
    iface.uplink = {
      name = "ens3";
      mac = mac_addr;
      matchOn = "mac";
      useDHCP = false;
      addr4 = "172.20.73.70/25";
      dns = [ "172.20.73.8" "9.9.9.9" ];
      routes = [
        {
          routeConfig = {
            Gateway = "172.20.73.1";
            GatewayOnLink = true;
            Destination = "0.0.0.0/0";
          };
        }
      ];
      };
      */

    wg = {
      addr4 = "10.13.37.6";
      prefix4 = 24;
      privateKeyFile = config.sops.secrets.wg-seckey.path;
      publicKey = "aNd+oXT3Im3cA0EqK+xL+MRjIx4l7qcXZk+Pe2vmRS8=";
    };
  };

}
