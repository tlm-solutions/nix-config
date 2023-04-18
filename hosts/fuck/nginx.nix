{ pkgs, config, lib, ... }: {
  services.nginx.enable = lib.mkForce false;

}
