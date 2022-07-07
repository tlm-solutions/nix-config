{
  inputs = {
    dump-dvb = {
      url = github:dump-dvb/dump-dvb.nix;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    microvm = {
      url = github:astro/microvm.nix;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = github:NixOS/nixpkgs/nixos-22.05;

    sops-nix = {
      url = github:Mic92/sops-nix;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stops = {
      url = github:dump-dvb/stop-names;
      flake = false;
    };
  };

  outputs =
    inputs@{ self
    , dump-dvb
    , microvm
    , nixpkgs
    , sops-nix
    , stops
    , ...
    }:
    let
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
      lib = pkgs.lib;

      data-hoarder-modules = [
        ./modules/base.nix
        ./modules/data-hoarder/data-accumulator.nix
        ./modules/data-hoarder/nginx.nix
        ./modules/data-hoarder/api.nix
        ./modules/data-hoarder/socket.nix
        ./modules/data-hoarder/map.nix
        ./modules/data-hoarder/file_sharing.nix
        ./modules/data-hoarder/grafana.nix
        ./modules/data-hoarder/website.nix
        ./modules/data-hoarder/documentation.nix
        ./modules/data-hoarder/clicky-bunty.nix
        ./modules/data-hoarder/secrets.nix
        ./modules/dump-dvb
        sops-nix.nixosModules.sops
        dump-dvb.nixosModules.default
        {
          nixpkgs.overlays = [
            dump-dvb.overlays.default
          ];
          dump-dvb.stopsJson = "${stops}/stops.json";
          dump-dvb.graphJson = "${stops}/graph.json";
        }
      ];

      diskModule = { config, lib, pkgs, ... }: {
        system.build.diskImage = import "${nixpkgs}/nixos/lib/make-disk-image.nix" {
          name = "${config.networking.hostName}-disk";
          partitionTableType = "efi";
          additionalSpace = "2G";
          copyChannel = false;
          config = config // {
            boot.growPartition = true;
          };
          inherit lib pkgs;
          postVM = ''
            mkdir -p $out/nix-support
            echo file binary-dist $diskImage >> $out/nix-support/hydra-build-products
          '';
        };
      };

      # function that generates a system with the given number
      generate_system = (number:
        {
          "traffic-stop-box-${toString number}" = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = { inherit inputs; };
            modules = [
              diskModule
              sops-nix.nixosModules.sops
              dump-dvb.nixosModules.default
              ./hosts/traffic-stop-boxes/configuration.nix
              ./hosts/traffic-stop-boxes/hardware-configuration.nix
              ./hardware/configuration-dell-wyse-3040.nix
              ./modules/base.nix
              ./modules/traffic-stop-boxes/radio_wireguard_client.nix
              ./modules/traffic-stop-boxes/secrets.nix
              ./modules/traffic-stop-boxes/radio-config.nix
              ./modules/dump-dvb
              {
                nixpkgs.overlays = [
                  dump-dvb.overlays.default
                ];
                dump-dvb.systemNumber = number;
                dump-dvb.stopsJson = "${stops}/stops.json";
              }
            ];
          };
        }
      );

      # list of accending system numbers
      id_list = [ 0 1 2 3 4 ];

      # attribute set of all traffic stop boxes
      stop_boxes = nixpkgs.lib.foldl (x: y: nixpkgs.lib.mergeAttrs x (generate_system y)) { } id_list;

      packages = {
        default = self.nixosConfigurations.traffic-stop-box-0.config.system.build.vm;
        traffic-stop-box = self.nixosConfigurations.traffic-stop-box-0.config.system.build.vm;
        staging-data-hoarder = self.nixosConfigurations.staging-data-hoarder.config.system.build.vm;
        data-hoarder = self.nixosConfigurations.data-hoarder.config.system.build.vm;
        mobile-box-vm = self.nixosConfigurations.mobile-box.config.system.build.vm;
        mobile-box-disk = self.nixosConfigurations.mobile-box.config.system.build.diskImage;
        staging-microvm = self.nixosConfigurations.staging-data-hoarder.config.microvm.declaredRunner;
      } // (import ./pkgs/deployment.nix { inherit self pkgs; systems = stop_boxes; });
    in
    {
      packages."x86_64-linux" = packages;

      nixosConfigurations = stop_boxes // {
        mobile-box = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            diskModule
            dump-dvb.nixosModules.default
            ./hosts/mobile-box/configuration.nix
            ./hosts/mobile-box/hardware-configuration.nix
            ./hardware/configuration-dell-wyse-3040.nix
            ./modules/base.nix
            ./modules/traffic-stop-boxes/mobile-box.nix
            ./modules/dump-dvb
            sops-nix.nixosModules.sops
            {
              nixpkgs.overlays = [
                dump-dvb.overlays.default
              ];
              dump-dvb.stopsJson = "${stops}/stops.json";
              dump-dvb.systemNumber = 130;
            }
          ];
        };
        data-hoarder = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/data-hoarder/configuration.nix
            ./hosts/data-hoarder/hardware-configuration.nix
            ./modules/data-hoarder/wireguard_server.nix
          ] ++ data-hoarder-modules;
        };
        staging-data-hoarder = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/staging/configuration.nix
            microvm.nixosModules.microvm
            {
              environment.systemPackages = with pkgs; [ tcpdump ];
            }
          ] ++ data-hoarder-modules;
        };
      };

      hydraJobs = {
        data-hoarder."x86_64-linux" = self.nixosConfigurations.data-hoarder.config.system.build.toplevel;
        staging-data-hoarder."x86_64-linux" = self.nixosConfigurations.staging-data-hoarder.config.system.build.toplevel;
        traffic-stop-box-0."x86_64-linux" = self.nixosConfigurations.traffic-stop-box-0.config.system.build.toplevel;
        traffic-stop-box-0-disk."x86_64-linux" = self.nixosConfigurations.traffic-stop-box-0.config.system.build.diskImage;
        mobile-box."x86_64-linux" = self.nixosConfigurations.mobile-box.config.system.build.toplevel;
        sops-binaries."x86_64-linux" = sops-nix.packages."x86_64-linux".sops-install-secrets;
      };
   };
}
