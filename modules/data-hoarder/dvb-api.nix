{ config, ... }:
let
  service_number = 1;
in {
  dump-dvb.api = {
    enable = true;
    GRPC = {
      host = "127.0.0.1";
      port = 50050 + service_number;
    };

    port = 9000 + service_number;
    graphFile = config.dump-dvb.graphJson;
    stopsFile = config.dump-dvb.stopsJson;
  };

}
