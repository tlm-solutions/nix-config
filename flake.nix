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
  };

  outputs =
    inputs@{ self
    , dump-dvb
    , microvm
    , nixpkgs
    , sops-nix
    , ...
    }:
    let
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
      lib = pkgs.lib;

      data-hoarder-modules = [
        ./modules/base.nix
        ./modules/data-hoarder
        ./modules/dump-dvb
        sops-nix.nixosModules.sops
        dump-dvb.nixosModules.default
        {
          nixpkgs.overlays = [
            dump-dvb.overlays.default
          ];
        }
      ];

      diskModule = { config, lib, pkgs, ... }: {
        boot.growPartition = true;
        system.build.diskImage = import ./modules/make-disk-image.nix {
          name = "${config.networking.hostName}-disk";
          partitionTableType = "efi";
          additionalSpace = "0G";
          copyChannel = false;
          inherit config lib pkgs;
          postVM = ''
            mkdir -p $out/nix-support
            echo file binary-dist $diskImage >> $out/nix-support/hydra-build-products
          '';
        };
      };

      # function that generates a system with the given number
      generate_system = (id: arch: extraModules:
        {
          "traffic-stop-box-${toString id}" = nixpkgs.lib.nixosSystem {
            system = arch;
            specialArgs = { inherit inputs; };
            modules = [
              sops-nix.nixosModules.sops
              dump-dvb.nixosModules.default
              ./hosts/traffic-stop-box
              ./modules/base.nix
              ./modules/dump-dvb
              {
                nixpkgs.overlays = [
                  dump-dvb.overlays.default
                ];
                dump-dvb.systemNumber = id;
              }
            ] ++ extraModules;
          };
        }
      );

      id_list = [
        {
          # Barkhausen Bau
          id = 0;
          arch = "x86_64-linux";
          extraModules = [
            ./hardware/dell-wyse-3040.nix
            diskModule
          ];
        }
        {
          # Zentralwerk
          id = 1;
          arch = "x86_64-linux";
          extraModules = [
            ./hardware/dell-wyse-3040.nix
            diskModule
          ];
        }
        {
          # Chemnitz
          id = 2;
          arch = "x86_64-linux";
          extraModules = [
            ./hardware/dell-wyse-3040.nix
            diskModule
          ];
        }
        {
          id = 3;
          arch = "aarch64-linux";
          extraModules = [
            (import "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix")
            ./hardware/rpi-3b-4b.nix
            ./modules/user-stop-box/user.nix
          ];
        }
      ];

      # attribute set of all traffic stop boxes
      stop_boxes = nixpkgs.lib.foldl (x: y: nixpkgs.lib.mergeAttrs x (generate_system y.id y.arch y.extraModules)) { } id_list;

      packages = {
        default = self.nixosConfigurations.traffic-stop-box-0.config.system.build.vm;
        traffic-stop-box = self.nixosConfigurations.traffic-stop-box-0.config.system.build.vm;
        staging-data-hoarder = self.nixosConfigurations.staging-data-hoarder.config.system.build.vm;
        data-hoarder = self.nixosConfigurations.data-hoarder.config.system.build.vm;
        mobile-box-vm = self.nixosConfigurations.mobile-box.config.system.build.vm;
        mobile-box-disk = self.nixosConfigurations.mobile-box.config.system.build.diskImage;
        staging-microvm = self.nixosConfigurations.staging-data-hoarder.config.microvm.declaredRunner;
        data-hoarder-microvm = self.nixosConfigurations.data-hoarder.config.microvm.declaredRunner;
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
            ./hardware/dell-wyse-3040.nix
            ./modules/base.nix
            ./modules/user-stop-box/user.nix
            ./modules/mobile-box/dresden.nix
            ./modules/dump-dvb
            sops-nix.nixosModules.sops
            {
              dump-dvb.telegramDecoder.configFile = "${self}/configs/mobile_box.json";
            }
          ];
        };
        data-hoarder = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            microvm.nixosModules.microvm
            ./hosts/data-hoarder/configuration.nix
            ./hosts/data-hoarder/wireguard_server.nix
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
        traffic-stop-box-3."aarch64-linux" = self.nixosConfigurations.traffic-stop-box-3.config.system.build.toplevel;
        traffic-stop-box-3-disk."aarch64-linux" = self.nixosConfigurations.traffic-stop-box-3.config.system.build.sdImage;
        mobile-box."x86_64-linux" = self.nixosConfigurations.mobile-box.config.system.build.toplevel;
        mobile-box-disk."x86_64-linux" = self.nixosConfigurations.mobile-box.config.system.build.diskImage;
        sops-binaries."x86_64-linux" = sops-nix.packages."x86_64-linux".sops-install-secrets;
      };
    };
}
