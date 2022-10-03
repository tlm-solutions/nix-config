# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, self, ... }:
let
  mac_addr = "00:de:5b:f9:e2:3d";
in
{
  microvm = {
    vcpu = 4;
    mem = 4096;
    hypervisor = "cloud-hypervisor";
    socket = "${config.networking.hostName}.socket";

    interfaces = [{
      type = "tap";
      id = "serv-dvb-stag";
      mac = mac_addr;
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

  networking.hostName = "staging-data-hoarder";

  time.timeZone = "Europe/Berlin";

  networking.useNetworkd = true;


  sops.defaultSopsFile = self + /secrets/data-hoarder-staging/secrets.yaml;
  deployment-dvb.net = {
    iface.uplink = {
      name = "ens3";
      mac = mac_addr;
      matchOn = "mac";
      useDHCP = false;
      addr4 = "172.20.73.64/25";
      dns = [ "172.20.73.8" "9.9.9.9" ];
      routes = [
        {
          routeConfig = {
            Gateway = "172.20.73.1";
            GatewayOnLink = true;
            Destination = "0.0.0.0/0";
          };
        }
      ];
    };

    wg = {
      addr4 = "10.13.37.5";
      prefix4 = 24;
      privateKeyFile = config.sops.secrets.wg-seckey.path;
      publicKey = "48hc7DVnUh2DHYhrxrNtNzj05MRecJO52j2niPImvkU=";
    };

  };

  deployment-dvb.domain = "staging.dvb.solutions";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}
