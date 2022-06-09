{ config, lib, ... }:
let

file = "/etc/nixos/configs" + "/config_${toString config.dump-dvb.systemNumber}.json"; # make sure that the box has our nix-config checkout, lol
receiver_configs = [
  { frequency = 170795000; offset = 19550; device = "hackrf=0"; } # dresden - barkhausen
  { frequency = 170795000; offset = 19500; device = "hackrf=0"; } # dresden - zentralwerk
  { frequency = 153850000; offset = 20000; device = ""; } # chemnitz
  { frequency = 170795000; offset = 19550; device = "hackrf=0"; } # dresden unused
  { frequency = 170795000; offset = 19550; device = "hackrf=0"; } # dresden unused
];

receiver_config = lib.elemAt receiver_configs config.dump-dvb.systemNumber;
in
{
  services.dump-dvb.gnuradio = {
    enable = true;
    frequency = receiver_config.frequency;
    offset = receiver_config.offset;
    device = receiver_config.device;
  };
  services.dump-dvb.telegram-decoder = {
    enable = true;
    server = [ "http://10.13.37.1" "http://10.13.37.5" ];
    configFile = file;
  };
}

