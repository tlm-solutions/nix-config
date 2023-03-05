{ config, lib, ... }: {

  options.TLMS = with lib; {
    useBinaryCache = mkOption {
      type = types.bool;
      default = true;
      description = ''Wether to use TLMS binary caches.'';
    };
  };

  config = lib.mkIf config.TLMS.useBinaryCache {
    nix.settings = {
      substituters = [
        "https://dump-dvb.cachix.org"
        "https://hydra.hq.c3d2.de"
      ];
      trusted-public-keys = [
        "dump-dvb.cachix.org-1:+Dq7gqpQG4YlLA2X3xJsG1v3BrlUGGpVtUKWk0dTyUU="
        "nix-serve.hq.c3d2.de:KZRGGnwOYzys6pxgM8jlur36RmkJQ/y8y62e52fj1ps="
      ];
    };
  };
}
