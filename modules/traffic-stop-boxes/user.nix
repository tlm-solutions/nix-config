{ pkgs, lib, ... }:
{
  users.mutableUsers = true;

  users.users.tramwarrior = {
    extraGroups = [ "wheel" ];
    group = "users";
    home = "/home/grue";
    isNormalUser = true;
    createHome = true;
    initialPassword = "changeme";
    uid = 1000;
  };
}
