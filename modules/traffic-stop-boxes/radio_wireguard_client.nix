{ config, pkgs, ... }:

{
  networking.firewall.allowedUDPPorts = [ 51820 ];

  networking.wg-quick.interfaces.wg-dvb = {
    address = [ "10.13.37.${toString (config.dvb-dump.systemNumber + 100)}/32" ];
    privateKeyFile = "/root/wg-seckey";
    postUp = ''
      ${pkgs.iputils}/bin/ping -c 10 10.13.37.1 || true
    '';

    peers = [{
      publicKey = "WDvCObJ0WgCCZ0ORV2q4sdXblBd8pOPZBmeWr97yphY=";
      allowedIPs = [ "10.13.37.0/24" ];
      endpoint = "academicstrokes.com:51820";
      persistentKeepalive = 25;
    }];

  };
}
