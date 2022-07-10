# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }:

{
  microvm = {
    hypervisor = "cloud-hypervisor";
    mem = 4096;
    vcpu = 8;
    interfaces = [ {
      type = "tap";
      id = "serv-dvb-prod";
      mac = "02:db:db:db:db:db";
    } ];
    shares = [ {
      source = "/nix/store";
      mountPoint = "/nix/.ro-store";
      tag = "store";
      proto = "virtiofs";
      socket = "store.socket";
    } ];
  };

  networking.hostName = "data-hoarder"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "Europe/Berlin";
  networking.interfaces.eth0 = {
    useDHCP = false;
    ipv4.addresses = [
      {
        address = "172.20.73.69";
        prefixLength = 25;
      }
    ];
  };

  networking.defaultGateway = "172.20.73.1";
  networking.nameservers = [ "172.20.73.8" "9.9.9.9" ];

  sops.defaultSopsFile = ../../secrets/data-hoarder/secrets.yaml;

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
  system.stateVersion = "21.11"; # Did you read the comment?

}
