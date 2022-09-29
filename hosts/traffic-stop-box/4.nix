{ self, ... }: {
  imports = [
    "${self}/hardware/dell-wyse-3040.nix"
  ];

              networking = nixpkgs.lib.mkForce {
                useDHCP = false;
                defaultGateway = "141.30.30.129";
                nameservers = [ "141.30.1.1" ];
                interfaces.enp1s0 = {
                  useDHCP = false;
                  ipv4.addresses = [
                    {
                      address = "141.30.30.149";
                      prefixLength = 25;
                    }
                  ];
                };
              };

}
