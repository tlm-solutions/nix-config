{ pkgs, lib, ... }:
{
  virtualisation.docker = {
    enable = true;
    # magic from marenz to make it work on ceph
    storageDriver = "devicemapper";
    extraOptions = "--storage-opt dm.basesize=40G --storage-opt dm.fs=xfs";
  };
  systemd.enableUnifiedCgroupHierarchy = false;

  # user to run the thing
  # jupyterlab container
  virtualisation.oci-containers = {
    backend = "docker";
    containers."jupyterlab-stateful" = {
      autoStart = true;
      ports = [ "8080:8080" ];
      volumes = [ "/var/lib/jupyter-volume:/workdir" ];
      imageFile = let
        package-string = lib.concatStringsSep " " [
          "numpy"
          "scipy"
          "pandas"
          "matplotlib"
        ];
      in
      (import ./jupyter-container.nix { inherit pkgs; packages = package-string; });
      image = "stateful-jupyterlab";
    };
  };

}
