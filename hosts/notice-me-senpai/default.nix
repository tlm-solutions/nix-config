# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, config, lib, ... }:
let
  mac_addr = "00:de:5b:f9:e2:3e";
in
{
  imports = [
    ./grafana.nix
  ];
  microvm = {
    vcpu = 2;
    mem = 1024 * 2;
    hypervisor = "cloud-hypervisor";
    socket = "${config.networking.hostName}.socket";
    storeOnDisk = true;
    storeDiskErofsFlags = [ "-zlz4hc,level=5" ];

    interfaces = [{
      type = "tap";
      id = "flpk-tlm-mon";
      mac = mac_addr;
    }];

    shares = [
      {
        source = "/var/lib/microvms/notice-me-senpai/etc";
        mountPoint = "/etc";
        tag = "etc";
        proto = "virtiofs";
        socket = "etc.socket";
      }
      {
        source = "/var/lib/microvms/notice-me-senpai/var";
        mountPoint = "/var";
        tag = "var";
        proto = "virtiofs";
        socket = "var.socket";
      }];
  };

  time.timeZone = "Europe/Berlin";

  networking.useNetworkd = true;

  sops.defaultSopsFile = ../../secrets/notice-me-senpai/secrets.yaml;
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
      addr4 = "45.158.40.162/27";
      dns = [ "1.1.1.1" ];
      routes = [
        {
          Gateway = "45.158.40.160";
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

  # NOTE: this has been updated to 6.6 due to an unfortunate situation at our colo
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_6;

  users.motd = lib.mkForce (builtins.readFile ./motd.txt);

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
