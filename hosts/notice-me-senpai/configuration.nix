{ self, pkgs, lib, ... }: {
  sops.defaultSopsFile = self + /secrets/notice-me-senpai/secrets.yaml;

  networking.hostName = "notice-me-senpai";

  boot = {
    tmp.cleanOnBoot = true;
    kernelPackages = pkgs.linuxPackages_latest;
  };

  users.motd = lib.mkForce (builtins.readFile ./motd.txt);

  system.stateVersion = "22.11";
}
