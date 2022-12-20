{pkgs, config, lib, ...}: {
  imports = [
    #./wireguard_server.nix
    ./secrets.nix
  ];
}
