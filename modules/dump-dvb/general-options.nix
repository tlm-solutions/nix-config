{ config, lib, ... }:
with lib; {
  options.dump-dvb.systemNumber = mkOption {
    type = types.int;
    default = 0;
    description = "number of the system";
  };
  options.dump-dvb.stopsJson = mkOption {
    type = types.path;
    default = ../configs/stops.json;
    description = "stops conig json";
  };
  options.dump-dvb.graphJson = mkOption {
    type = types.path;
    default = ../configs/graph.json;
    description = "graph json containing the network graphs";
  };

  options.dump-dvb.domain = mkOption {
    type = types.str;
    default = "dvb.solutions";
    description = "domain the server is running on";
  };
}


