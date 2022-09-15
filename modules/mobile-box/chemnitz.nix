{ pkgs, config, lib, ... }:
let reciever_conf = { frequency = 153850000; offset = 25000; device = ""; RF = 14; IF = 32; BB = 42; }; # chemnitz
in {
  dump-dvb = {
    gnuradio = {
      enable = true;
      device = reciever_conf.device;
      frequency = reciever_conf.frequency;
      offset = reciever_conf.offset;
      RF = reciever_conf.RF;
      IF = reciever_conf.IF;
      BB = reciever_conf.BB;
    };
    telegramDecoder = {
      enable = true;
      server = [ "http://127.0.0.1:7680" ];
      offline = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 config.dump-dvb.wartrammer.port ];
  dump-dvb.wartrammer.enable = true;
  systemd.services."start-wifi-hotspot" = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
    };
    script = ''
      ${pkgs.linux-router}/bin/lnxrouter --ap wlp0s20u2 dump-dvb -g 10.3.141.1 -p trolling-dvb
    '';
  };

}
