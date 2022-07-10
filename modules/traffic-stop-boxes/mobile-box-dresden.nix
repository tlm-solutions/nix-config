let
  file = ../../configs/mobile_box.json;
in
{
  dump-dvb = {
    gnuradio = {
    enable = true;
    device = "hackrf=0";
    frequency = 170795000;
    offset = 19550;
  }
  telegram-decoder = {
    enable = true;
    server = [ "http://127.0.0.1:8080" ];
    configFile = file;
  };
  data-accumulator = {
    enable = true;
    host = "0.0.0.0";
    port = 8080;
    DB.backend = "CSV";
    CSVFile = "/var/lib/data-accumulator/formatted.csv";
  };
  wartrammer.enable = true;
};
}
