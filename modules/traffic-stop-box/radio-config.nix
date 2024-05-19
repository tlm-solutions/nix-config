{ self, config, lib, registry, ... }:
{
  TLMS.r09-receiver = {
    enable = true;
  } // registry.r09-receiver;

  # find all the servers with data-accumulator configured
  TLMS.telegramDecoder = let
    registries = builtins.attrValues (builtins.mapAttrs (name: value: value.specialArgs.registry) self.unevaluatedNixosConfigurations);
    filteredDataHoarders = builtins.filter (other: other ? port-data_accumulator) registries;
    urlFromRegistry = other: "http://${other.wgAddr4}:${toString other.port-data_accumulator.port}";
  in {
    enable = true;
    server = builtins.map urlFromRegistry filteredDataHoarders;
    configFile = registry.telegramDecoderConfig;
    authTokenFile = config.sops.secrets.telegram-decoder-token.path;
  };
}
