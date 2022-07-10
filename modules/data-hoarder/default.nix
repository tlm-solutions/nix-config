{ config, ... }: {
  imports = [
    ./clicky-bunty.nix
    ./data-accumulator.nix
    ./documentation.nix
    ./file_sharing.nix
    ./grafana.nix
    ./map.nix
    ./nginx.nix
    ./secrets.nix
    ./socket.nix
    ./website.nix
  ];
}
