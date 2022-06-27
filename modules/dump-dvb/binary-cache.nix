{ config, lib, ... }: {

  options.dump-dvb = {
    useBinaryCache = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''Wether to use dump-dvb binary caches.'';
    };
  };

  config = lib.mkIf config.dump-dvb.useBinaryCache {
    nix = {
      binaryCaches = [
        "https://dump-dvb.cachix.org"
        "https://nix-serve.hq.c3d2.de"
      ];
      binaryCachePublicKeys = [
        "dump-dvb.cachix.org-1:+Dq7gqpQG4YlLA2X3xJsG1v3BrlUGGpVtUKWk0dTyUU="
        "nix-serve.hq.c3d2.de:KZRGGnwOYzys6pxgM8jlur36RmkJQ/y8y62e52fj1ps="
      ];
    };
  };
}
