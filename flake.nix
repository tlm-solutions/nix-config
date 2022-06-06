{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-22.05;

    naersk = {
      url = github:nix-community/naersk;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    microvm = {
      url = github:astro/microvm.nix;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    radio-conf = {
      url = github:dump-dvb/radio-conf;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    data-accumulator = {
      url = github:dump-dvb/data-accumulator;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    decode-server = {
      url = github:dump-dvb/decode-server;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dvb-api = {
      url = github:dump-dvb/dvb-api;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stops = {
      url = github:dump-dvb/stop-names;
      flake = false;
    };

    windshield = {
      url = github:dump-dvb/windshield;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    docs = {
      url = github:dump-dvb/documentation;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wartrammer = {
      url = github:dump-dvb/wartrammer-40k;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    clicky-bunty-server = {
      url = github:dump-dvb/clicky-bunty-server;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = github:Mic92/sops-nix;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, naersk, microvm, radio-conf, data-accumulator, decode-server, dvb-api, stops, windshield, docs, wartrammer, clicky-bunty-server, sops-nix, ... }@inputs:
    let
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
      lib = pkgs.lib;

      data-hoarder-modules = [
        ./modules/base.nix
        ./modules/options.nix
        ./modules/data-hoarder/data-accumulator.nix
        ./modules/data-hoarder/nginx.nix
        ./modules/data-hoarder/public_api.nix
        ./modules/data-hoarder/map.nix
        ./modules/data-hoarder/file_sharing.nix
        ./modules/data-hoarder/grafana.nix
        ./modules/data-hoarder/website.nix
        ./modules/data-hoarder/documentation.nix
        ./modules/data-hoarder/clicky-bunty.nix
        ./modules/data-hoarder/secrets.nix
        sops-nix.nixosModules.sops
        {
          nixpkgs.overlays = [
            data-accumulator.overlay."x86_64-linux"
            dvb-api.overlay."x86_64-linux"
            windshield.overlay."x86_64-linux"
            docs.overlay."x86_64-linux"
            clicky-bunty-server.overlay."x86_64-linux"
          ];
          dvb-dump.stopsJson = "${stops}/stops.json";
          dvb-dump.graphJson = "${stops}/graph.json";
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
              ./hosts/traffic-stop-boxes/configuration.nix
              ./hosts/traffic-stop-boxes/hardware-configuration.nix
              ./hardware/configuration-dell-wyse-3040.nix
              ./modules/base.nix
              ./modules/options.nix
              ./modules/traffic-stop-boxes/gnuradio.nix
              ./modules/traffic-stop-boxes/radio_wireguard_client.nix
              ./modules/traffic-stop-boxes/secrets.nix
              {
                nixpkgs.overlays = [ radio-conf.overlay."x86_64-linux" decode-server.overlay."x86_64-linux" ];
                dvb-dump.systemNumber = number;
                dvb-dump.stopsJson = "${stops}/stops.json";
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
        traffic-stop-box = self.nixosConfigurations.traffic-stop-box-0.config.system.build.vm;
        staging-data-hoarder = self.nixosConfigurations.staging-data-hoarder.config.system.build.vm;
        data-hoarder = self.nixosConfigurations.data-hoarder.config.system.build.vm;
        mobile-box-vm = self.nixosConfigurations.mobile-box.config.system.build.vm;
        mobile-box-disk = self.nixosConfigurations.mobile-box.config.system.build.diskImage;
        staging-microvm = self.nixosConfigurations.staging-data-hoarder.config.microvm.declaredRunner;
      } // (import ./pkgs/deployment.nix { inherit self pkgs; systems = stop_boxes; });
    in
    {
      defaultPackage."x86_64-linux" = self.nixosConfigurations.traffic-stop-box-0.config.system.build.vm;
      packages."x86_64-linux" = packages;

      nixosConfigurations = stop_boxes // {
        mobile-box = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            diskModule
            ./hosts/mobile-box/configuration.nix
            ./hosts/mobile-box/hardware-configuration.nix
            ./hardware/configuration-dell-wyse-3040.nix
            ./modules/base.nix
            ./modules/options.nix
            ./modules/traffic-stop-boxes/mobile-box.nix
            sops-nix.nixosModules.sops
            {
              nixpkgs.overlays = [
                radio-conf.overlay."x86_64-linux"
                decode-server.overlay."x86_64-linux"
                data-accumulator.overlay."x86_64-linux"
                wartrammer.overlay."x86_64-linux"
              ];
              dvb-dump.stopsJson = "${stops}/stops.json";
              dvb-dump.systemNumber = 130;
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
          ] ++ data-hoarder-modules;
        };
      };

      hydraJobs = {
        data-hoarder."x86_64-linux" = self.nixosConfigurations.data-hoarder.config.system.build.toplevel;
        staging-data-hoarder."x86_64-linux" = self.nixosConfigurations.staging-data-hoarder.config.system.build.toplevel;
        traffic-stop-box-0."x86_64-linux" = self.nixosConfigurations.traffic-stop-box-0.config.system.build.toplevel;
        traffic-stop-box-0-disk."x86_64-linux" = self.nixosConfigurations.traffic-stop-box-0.config.system.build.diskImage;
        mobile-box."x86_64-linux" = self.nixosConfigurations.mobile-box.config.system.build.toplevel;
        mobile-box-disk."x86_64-linux" = self.nixosConfigurations.mobile-box.config.system.build.diskImage;
        sops-binaries."x86_64-linux" = sops-nix.packages."x86_64-linux".sops-install-secrets;
      };
    };
}
