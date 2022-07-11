{ pkgs, ... }:
  {
    dump-dvb = {
      gnuradio = {
        enable = true;
        device = "hackrf=0";
        frequency = 170795000;
        offset = 19550;
      };
      telegramDecoder = {
        enable = true;
        server = [ "http://127.0.0.1:8080" ];
      };
      dataAccumulator = {
        enable = true;
        host = "0.0.0.0";
        port = 8080;
        DB.backend = "CSVFILE";
        CSVFile = "/var/lib/data-accumulator/formatted.csv";
      };
    };
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
