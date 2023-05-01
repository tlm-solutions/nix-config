{ self, pkgs, ... }: {
  sops.defaultSopsFile = self + /secrets/notice-me-senpai/secrets.yaml;

  networking.hostName = "notice-me-senpai";

  boot = {
    cleanTmpDir = true;
    kernelPackages = pkgs.linuxPackages_latest;
  };

  system.stateVersion = "22.11";
}
