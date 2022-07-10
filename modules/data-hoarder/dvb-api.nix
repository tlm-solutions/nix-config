{ config, ... }:
{
  dump-dvb.api = {
    enable = true;
    GRPCHost = "127.0.0.1";
    GRPCPort = 50051;
    port = 9001;
    graphFile = config.dump-dvb.graphJson;
    stopsFile = config.dump-dvb.stopsJson;
  };

}
