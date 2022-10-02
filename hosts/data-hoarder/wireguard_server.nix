{ config, ... }:
let
  port = 51820;
in
{
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  networking.firewall.allowedUDPPorts = [ port ];

    deployment-dvb.net.wg = {
      ownEndpoint.host = "endpoint.dvb.solutions";
      ownEndpoint.port = port;
      addr4 = "10.13.37.1";
      prefix4 = 24;
      privateKeyFile = config.sops.secrets.wg-seckey.path;
      publicKey = "WDvCObJ0WgCCZ0ORV2q4sdXblBd8pOPZBmeWr97yphY=";
      extraPeers = [
        {
          # Tassilo
          publicKey = "vgo3le9xrFsIbbDZsAhQZpIlX+TuWjfEyUcwkoqUl2Y=";
          addr4 = "10.13.37.2";
        }
        {
          # oxa
          publicKey = "QbaQaGqudRXIh03IbBNATfBZfpMLmwihlwLs6W9+P1c=";
          addr4 = "10.13.37.3";
        }
        {
          # traffic-stop-box-7
          publicKey = "sMsdY7dSjlYeIFMqjkh4pJ/ftAYXlyRuxDGbdnGLpEQ=";
          allowedIPs = [ "10.13.37.107/32" ];
          persistentKeepalive = 25;
        }
        {
          # marenz
          publicKey = "XJddbPj6Zdtn4roi6UWGuR2EA81juMmlaUOuMSLi2FM=";
          addr4 = "10.13.37.4";
        }
      ];
    };
}
