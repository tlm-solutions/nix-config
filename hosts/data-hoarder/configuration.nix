# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }:

{
  networking.hostName = "data-hoarder"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "Europe/Berlin";
  networking.interfaces.ens3 = {
    useDHCP = false;
    ipv4.addresses = [
      {
        address = "192.109.108.52";
        prefixLength = 27;
      }
    ];
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
  system.stateVersion = "21.11"; # Did you read the comment?

}
