{ config, ... }:

{

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  networking.wg-quick.interfaces = {
    wg-dvb = {
      address = [ "10.13.37.1/32" ];
      privateKeyFile = "/root/wg-seckey";
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
        # { # marenz
        # { # marenz
        #   publicKey = "";
        #   allowedIPs = [ "10.13.37.4/32" ];
        #   persistentKeepalive = 25;
        # }
      ];
    };
  };
}


