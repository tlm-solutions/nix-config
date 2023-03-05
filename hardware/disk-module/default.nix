{ config, lib, pkgs, ... }:
{
  boot.growPartition = true;
  system.build.diskImage = import ./make-disk-image.nix {
    name = "${config.networking.hostName}-disk";
    partitionTableType = "efi";
    additionalSpace = "0G";
    copyChannel = false;
    inherit config lib pkgs;
    postVM = ''
      mkdir -p $out/nix-support
      echo file binary-dist $diskImage >> $out/nix-support/hydra-build-products
    '';
  };
  fileSystems."/".autoResize = true;
}
