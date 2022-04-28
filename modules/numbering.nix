{ config, lib, ... }:
with lib; {
  options.dvb-dump.systemNumber = mkOption {
    type = types.int;
    default = 0;
    description = "number of the system";
  };
}


