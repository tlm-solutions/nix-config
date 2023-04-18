{ config, ... }:
let
  service_number = 6;
in
{
  TLMS.bureaucrat = {
    enable = true;
    grpc = {
      host = "127.0.0.1";
      port = 50050 + service_number;
    };
    redis = {
      host = config.services.redis.servers."state".bind;
      port = config.services.redis.servers."state".port;
    };
  };

  services = {
    redis.servers."state" = {
      enable = true;
      bind = "127.0.0.1";
      port = 5314;
    };
  };
}
