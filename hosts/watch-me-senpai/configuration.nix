{ self, ... }: 
let
  mac_addr =  "03:db:db:db:db:db";
in {
  microvm = {
    hypervisor = "cloud-hypervisor";
    mem = 4096;
    vcpu = 2;
    interfaces = [{
      type = "tap";
      id = "serv-dvb-prod";
      mac = mac_addr;
    }];
    shares = [
      {
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
        tag = "store";
        proto = "virtiofs";
        socket = "store.socket";
      }
      {
        source = "/var/lib/microvms/watch-me-senpai/etc";
        mountPoint = "/etc";
        tag = "etc";
        proto = "virtiofs";
        socket = "etc.socket";
      }
      {
        source = "/var/lib/microvms/watch-me-senpai/var";
        mountPoint = "/var";
        tag = "var";
        proto = "virtiofs";
        socket = "var.socket";
      }
    ];
  };

  networking.hostName = "watch-me-senpai"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  sops.defaultSopsFile = self + /secrets/watch-me-senpai/secrets.yaml;

  system.stateVersion = "22.05";
}
