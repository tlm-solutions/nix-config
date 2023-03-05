{ lib, pkgs, config, ... }:
with lib; {
  options.TLMS = {
    stopsJson = mkOption {
      type = types.str;
      default = "";
      description = "stops.json location";
    };
    graphJson = mkOption {
      type = types.str;
      default = "";
      description = "graph.json location";
    };
  };
}
