{ lib, ... }:
with lib; {
  options = {
    deployment-dvb.systemNumber = mkOption {
      type = types.int;
      default = 0;
      description = "number of the system";
    };

    deployment-dvb.domain = mkOption {
      type = types.str;
      default = "dvb.solutions";
      description = "domain the server is running on";
    };
  };
}


