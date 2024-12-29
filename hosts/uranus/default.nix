# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, ... }:
let
  mac_addr = "00:de:5b:f9:be:ef";
in
{
  imports = [
    ./stateful-jupyter.nix
    ./stateless-jupyter.nix
  ];

  microvm = {
    vcpu = 4;
    mem = 1024 * 4;
    hypervisor = "cloud-hypervisor";
    socket = "${config.networking.hostName}.socket";

    interfaces = [{
      type = "tap";
      id = "serv-dvb-anus";
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
        source = "/var/lib/microvms/uranus/etc";
        mountPoint = "/etc";
        tag = "etc";
        proto = "virtiofs";
        socket = "etc.socket";
      }
      {
        source = "/var/lib/microvms/uranus/var";
        mountPoint = "/var";
        tag = "var";
        proto = "virtiofs";
        socket = "var.socket";
      }
    ];
  };

  time.timeZone = "Europe/Berlin";

  networking.useNetworkd = true;


  sops.defaultSopsFile = ../../secrets/uranus/secrets.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  sops.secrets.wg-seckey = {
    owner = config.users.users.systemd-network.name;
  };
  deployment-TLMS.net = {
    iface.uplink = {
      name = "ens3";
      mac = mac_addr;
      matchOn = "mac";
      useDHCP = false;
      addr4 = "172.20.73.37/25";
      dns = [ "172.20.73.8" "9.9.9.9" ];
      routes = [
        {
          Gateway = "172.20.73.1";
          GatewayOnLink = true;
          Destination = "0.0.0.0/0";
        }
      ];
    };

    wg = {
      prefix4 = 24;
      privateKeyFile = config.sops.secrets.wg-seckey.path;
    };

  };

  networking.firewall.allowedTCPPorts = [ 80 443 8080 22 ];

  users.motd = lib.mkForce (builtins.readFile ./motd.txt);

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
