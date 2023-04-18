{ pkgs, config, lib, ... }:
let
  mac_addr = "00:de:5b:f9:e2:3d";
in
{
  imports = [
    ../TLMS/default.nix
    ./secrets.nix
  ];

  sops.defaultSopsFile = ../../secrets/watch-me-senpai/secrets.yaml;
  deployment-TLMS.net = {
    iface.uplink = {
      name = "eth0";
      mac = mac_addr;
      matchOn = "mac";
      useDHCP = false;
      addr4 = "192.168.92.49/42";
      dns = [ "8.8.8.8" "9.9.9.9" ];
      routes = [
        {
          routeConfig = {
            Gateway = "192.168.92.1";
            GatewayOnLink = true;
            Destination = "0.0.0.0/0";
          };
        }
      ];
    };
    wg = {
      addr4 = "10.13.37.6";
      prefix4 = 24;
      privateKeyFile = config.sops.secrets.wg-seckey.path;
      publicKey = "aNd+oXT3Im3cA0EqK+xL+MRjIx4l7qcXZk+Pe2vmRS8=";
    };

  };

  deployment-TLMS.domain = "dvb.solutions";
}
