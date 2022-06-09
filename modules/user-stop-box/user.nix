{ pkgs, lib, ... }:
{
  users.mutableUsers = true;

  users.users.tramwarrior = {
    extraGroups = [ "wheel" "plugdev" ];
    group = "users";
    home = "/home/tramwarrior";
    isNormalUser = true;
    createHome = true;
    initialPassword = "changeme";
    uid = 1000;
  };
}
