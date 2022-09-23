{ lib, ... }:
with lib; {
  options = {
    ddvbDeployment.systemNumber = mkOption {
      type = types.int;
      default = 0;
      description = "number of the system";
    };

    ddvbDeployment.domain = mkOption {
      type = types.str;
      default = "dvb.solutions";
      description = "domain the server is running on";
    };
  };
}


