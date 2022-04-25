{ config, ... }:

{
  networking.wg-quick.interfaces.wg-dvb = {
    address = "10.13.37.5/32"
    privateKeyFile = "/root/wg-seckey";

    peers = [{
      publicKey = "WDvCObJ0WgCCZ0ORV2q4sdXblBd8pOPZBmeWr97yphY=";
      allowedIPs = "10.13.37.0/24";
      endpoint = "academicstrokes.com:51820";
      persistentKeepalive = 25;
  }];

  };
}
