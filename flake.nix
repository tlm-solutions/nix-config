{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-21.11;

    sops-nix.url = github:Mic92/sops-nix;
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    naersk = {
      url = github:nix-community/naersk;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    radio-conf = {
      url = github:dump-dvb/radio-conf;
    };

    data-accumulator = {
      url = github:dump-dvb/data-accumulator;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    decode-server = {
      url = github:dump-dvb/decode-server;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, sops-nix, naersk, radio-conf, data-accumulator, decode-server, ... }@inputs:
  let
    generate_system = (number: 
      {"traffic-stop-box-${toString number}" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/traffic-stop-box/configuration.nix
            ./modules/gnuradio.nix
            ./modules/radio_wireguard_client.nix
            ./modules/numbering.nix
            {
              nixpkgs.overlays = [ radio-conf.overlay."x86_64-linux" decode-server.overlay."x86_64-linux" ];
              dvb-dump.systemNumber = number;
            }
          ];
        };
      }
      );

    # increment this number if you want to add a new system
    numberOfSystems = 1;
    # list of accending system numbers
    id_list = ((num: if num == 0 then [ num ] else [num] ++ (id_list num - 1)) (numberOfSystems - 1));
    # list of nixos systems
    list_of_systems = builtins.map generate_system id_list;
    # attribute set of all traffic stop boxes
    stop_boxes = nixpkgs.lib.foldr (x: y: nixpkgs.lib.mergeAttrs x y) {} list_of_systems;
  in {
      defaultPackage."x86_64-linux" = self.nixosConfigurations.traffic-stop-box-0.config.system.build.vm;
      packages."x86_64-linux".traffic-stop-box = self.nixosConfigurations.traffic-stop-box-0.config.system.build.vm;
      packages."x86_64-linux".data-hoarder = self.nixosConfigurations.data-hoarder.config.system.build.vm;

      nixosConfigurations = (nixpkgs.lib.mergeAttrs stop_boxes
      {
        data-hoarder = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/data-hoarder/configuration.nix
            ./modules/data-accumulator.nix
            ./modules/nginx.nix
	        ./modules/wireguard_server.nix
            {
              nixpkgs.overlays = [ data-accumulator.overlay."x86_64-linux" ];
            }
          ];
        };
      });
    };
}
