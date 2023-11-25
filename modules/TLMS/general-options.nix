{ lib, ... }:
with lib; {
  options = {
    deployment-TLMS.domain = mkOption {
      type = types.str;
      default = "tlm.solutions";
      description = "domain the server is running on";
    };
  };
}


