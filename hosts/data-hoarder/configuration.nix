# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  microvm = {
    vcpu = 4;
    mem = 4096;
    hypervisor = "cloud-hypervisor";
    socket = "${config.networking.hostName}.socket";

    interfaces = [{
      type = "tap";
      id = "serv-data-hoarder";
      mac = "00:de:5b:f9:e3:3e";
    }];

    shares = [{
      source = "/nix/store";
      mountPoint = "/nix/.ro-store";
      tag = "store";
      proto = "virtiofs";
      socket = "store.socket";
    }
      {
        source = "/var/lib/microvms/data-hoarder/etc";
        mountPoint = "/etc";
        tag = "etc";
        proto = "virtiofs";
        socket = "etc.socket";
      }
      {
        source = "/var/lib/microvms/data-hoarder/var";
        mountPoint = "/var";
        tag = "var";
        proto = "virtiofs";
        socket = "var.socket";
      }];
  };

  networking.hostName = "data-hoarder"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "Europe/Berlin";
  networking.interfaces.eth0 = {
    useDHCP = false;
    ipv4.addresses = [{
      address = "172.20.73.69";
      prefixLength = 25;
    }];
  };
  environment.systemPackages = with pkgs; [ influxdb ];

  networking.defaultGateway = "172.20.73.1";
  networking.nameservers = [ "172.20.73.8" "9.9.9.9" ];

  sops.defaultSopsFile = ../../secrets/data-hoarder/secrets.yaml;

  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 80 443 22 51820 ];
  networking.firewall.trustedInterfaces = [ "wg-dvb" ];
  networking.firewall.allowedUDPPorts = [ 22 51820 ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05";

  security.acme.defaults.server = "https://acme-staging-v02.api.letsencrypt.org/directory";

}
