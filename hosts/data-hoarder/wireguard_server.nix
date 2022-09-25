{ config, ... }:

{
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  networking.wg-quick.interfaces = {
    wg-dvb = {
      address = [ "10.13.37.1/32" ];
      privateKeyFile = config.sops.secrets.wg-seckey.path;
      listenPort = 51820;
      peers = [
        {
          # Tassilo
          publicKey = "vgo3le9xrFsIbbDZsAhQZpIlX+TuWjfEyUcwkoqUl2Y=";
          allowedIPs = [ "10.13.37.2/32" ];
          persistentKeepalive = 25;
        }
        {
          # oxa
          publicKey = "QbaQaGqudRXIh03IbBNATfBZfpMLmwihlwLs6W9+P1c=";
          allowedIPs = [ "10.13.37.3/32" ];
          persistentKeepalive = 25;
        }
        # data hoarder staging
        {
          publicKey = "48hc7DVnUh2DHYhrxrNtNzj05MRecJO52j2niPImvkU=";
          allowedIPs = [ "10.13.37.5/32" ];
          persistentKeepalive = 25;
        }
        {
          # traffic-stop-box-0
          publicKey = "qyStvzZdoqcjJJQckw4ZwvsQUa+8TBWtnsRxURqanno=";
          allowedIPs = [ "10.13.37.100/32" ];
          persistentKeepalive = 25;
        }
        {
          # traffic-stop-box-1
          publicKey = "dOPobdvfphx0EHmU7dd5ihslFzZi17XgRDQLMIUYa1w=";
          allowedIPs = [ "10.13.37.101/32" ];
          persistentKeepalive = 25;
        }
        {
          # traffic-stop-box-2
          publicKey = "4TUQCToGNhjsCgV9elYE/91Vd/RvMgvMXtF/1Dzlvxo=";
          allowedIPs = [ "10.13.37.102/32" ];
          persistentKeepalive = 25;
        }
        {
          # traffic-stop-box-3
          publicKey = "w3AT3EahW1sCK8ZsR7sDTcQj1McXYeWx7fnfQFA7i3o=";
          allowedIPs = [ "10.13.37.103/32" ];
          persistentKeepalive = 25;
        }
        {
          # traffic-stop-box-4
          publicKey = "B0wPH0jUxaatRncHMkgDEQ+DzvlbTBrVJY4etxqQgG8=";
          allowedIPs = [ "10.13.37.104/32" ];
          persistentKeepalive = 25;
        }
        {
          # traffic-stop-box-5
          publicKey = "bGMO3+BuMbNMnqgt+1lEKAwCVi3BrtpcZlVf9ULcmkw=";
          allowedIPs = [ "10.13.37.105/32" ];
          persistentKeepalive = 25;
        }
        {
          # traffic-stop-box-6
          publicKey = "NuLDNmxuHHzDXJSIOPSoihEhLWjARRtavuQvWirNR2I=";
          allowedIPs = [ "10.13.37.106/32" ];
          persistentKeepalive = 25;
        }
        {
          # marenz
          publicKey = "XJddbPj6Zdtn4roi6UWGuR2EA81juMmlaUOuMSLi2FM=";
          allowedIPs = [ "10.13.37.4/32" ];
          persistentKeepalive = 25;
        }
      ];
    };
  };
}


