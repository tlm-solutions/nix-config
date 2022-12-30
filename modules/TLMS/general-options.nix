{ lib, ... }:
with lib; {
  options = {
    deployment-TLMS.systemNumber = mkOption {
      type = types.int;
      default = 0;
      description = "number of the system";
    };

    deployment-TLMS.domain = mkOption {
      type = types.str;
      default = "dvb.solutions";
      description = "domain the server is running on";
    };
  };
}


