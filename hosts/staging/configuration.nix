# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  microvm = {
    vcpu = 4;
    mem = 4096;
    hypervisor = "cloud-hypervisor";
    socket = "${config.networking.hostName}.socket";

    interfaces = [{
      type = "tap";
      id = "serv-dvb-stag";
      mac = "00:de:5b:f9:e2:3d";
    }];

    shares = [{
      source = "/nix/store";
      mountPoint = "/nix/.ro-store";
      tag = "store";
      proto = "virtiofs";
      socket = "store.socket";
    }
      {
        source = "/var/lib/microvms/staging-data-hoarder/etc";
        mountPoint = "/etc";
        tag = "etc";
        proto = "virtiofs";
        socket = "etc.socket";
      }
      {
        source = "/var/lib/microvms/staging-data-hoarder/var";
        mountPoint = "/var";
        tag = "var";
        proto = "virtiofs";
        socket = "var.socket";
      }];
  };

  networking.hostName = "staging-data-hoarder"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "Europe/Berlin";
  networking.interfaces.eth0 = {
    useDHCP = false;
    ipv4.addresses = [{
      address = "172.20.73.64";
      prefixLength = 25;
    }];
  };

  networking.defaultGateway = "172.20.73.1";
  networking.nameservers = [ "172.20.73.8" "9.9.9.9" ];

  sops.defaultSopsFile = ../../secrets/data-hoarder-staging/secrets.yaml;
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 80 443 22 51820 ];
  networking.firewall.trustedInterfaces = [ "wg-dvb" ];
  networking.firewall.allowedUDPPorts = [ 22 51820 ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  ddvbDeployment.domain = "staging.dvb.solutions";
  networking.wg-quick.interfaces.wg-dvb = {
    address = [ "10.13.37.5/32" ];
    privateKeyFile = config.sops.secrets.wg-seckey.path;
    postUp = '' ${pkgs.iputils}/bin/ping -c 10 10.13.37.1 || true '';
    peers = [
      {
        publicKey = "WDvCObJ0WgCCZ0ORV2q4sdXblBd8pOPZBmeWr97yphY=";
        allowedIPs = [ "10.13.37.0/24" ];
        endpoint = "academicstrokes.com:51820";
        persistentKeepalive = 25;
      }
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}
