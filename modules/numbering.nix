{ config, lib, ... }:
with lib; {
  options.dvb-dump.systemNumber = mkOption {
    type = types.int;
    default = 0;
    description = "number of the system";
  };
  options.dvb-dump.stopsJson = mkOption {
    type = types.path;
    default = ../configs/stops.json;
    description = "stops conig json";
  };
  options.dvb-dump.graphJson = mkOption {
    type = types.path;
    default = ../configs/graph.json;
    description = "graph json containing the network graphs";
  };

}


