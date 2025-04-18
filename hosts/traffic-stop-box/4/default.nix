{ self, ... }:
let eth = "enp1s0"; in
{
  imports = [
    "${self}/hardware/dell-wyse-3040.nix"
  ];

  networking.useDHCP = false;
  networking.interfaces."${eth}".useDHCP = false;

  deployment-TLMS.net.iface.uplink = {
    name = eth;
    useDHCP = false;
    addr4 = "141.30.30.149/25";
    dns = [ "141.30.1.1" "9.9.9.9" ];
    routes = [
      {
        Gateway = "141.30.30.129";
        Destination = "0.0.0.0/0";
      }
    ];
  };

  TLMS.telegramDecoder.errorCorrection = false;
}
