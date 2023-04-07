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
        "https://tlm-solutions.cachix.org"
        "https://nix-cache.hq.c3d2.de"
      ];
      trusted-public-keys = [
        "tlm-solutions.cachix.org-1:J7qT6AvoNWPSj+59ed5bNESj35DLJNaROqga1EjVIoA="
        "nix-cache.hq.c3d2.de:KZRGGnwOYzys6pxgM8jlur36RmkJQ/y8y62e52fj1ps="
      ];
    };
  };
}
