{ config, ... }: {
  imports = [
    ./documentation.nix
    ./file_sharing.nix
    ./grafana.nix
    ./map.nix
    ./nginx.nix
    ./secrets.nix
    ./socket.nix
    ./website.nix
  ];
  dump-dvb = {
    clickyBuntyServer.enable = true;
    dataAccumulator.enable = true;
  };
}
