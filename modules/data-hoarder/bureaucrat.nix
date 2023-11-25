{ config, registry, ... }: {
  TLMS.bureaucrat = {
    enable = true;
    grpc = registry.grpc-chemo-bureaucrat;
    redis = registry.redis-bureaucrat-lizard;
  };

  services = {
    redis.servers."state" = with registry.redis-bureaucrat-lizard; {
      inherit port;
      enable = true;
      bind = host;
    };
  };
}
