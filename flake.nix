{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-21.11;

    sops-nix.url = github:Mic92/sops-nix;
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    naersk = {
      url = github:nix-community/naersk;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    radio-conf.url = github:dump-dvb/radio-conf;
    data-accumulator.url = github:dump-dvb/data-accumulator;
  };

  outputs = { self, nixpkgs, sops-nix, naersk, radio-conf, data-accumulator, ... }@inputs:
    {
      defaultPackage."x86_64-linux" = self.nixosConfigurations.traffic-stop-box.config.system.build.vm;
      packages."x86_64-linux".traffic-stop-box = self.nixosConfigurations.traffic-stop-box.config.system.build.vm;
      packages."x86_64-linux".data-hoarder = self.nixosConfigurations.data-hoarder.config.system.build.vm;

      nixosConfigurations = {
        traffic-stop-box = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/traffic-stop-box/configuration.nix
            ./modules/gnuradio.nix
            ./modules/radio_wireguard_client.nix
            {
              nixpkgs.overlays = [ radio-conf.overlay."x86_64-linux" ];
            }
          ];
        };
        data-hoarder = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/data-hoarder/configuration.nix
            ./modules/data-accumulator.nix
            ./modules/nginx.nix
            {
              nixpkgs.overlays = [ data-accumulator.overlay."x86_64-linux" ];
            }
          ];
        };
      };
    };
}
