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
        ./modules/data-hoarder
        ./modules/dump-dvb
        sops-nix.nixosModules.sops
        dump-dvb.nixosModules.default
        {
          nixpkgs.overlays = [
            dump-dvb.overlays.default
            (final: pref: {
              options-docs = (pkgs.nixosOptionsDoc {
                options = self.nixosConfigurations.data-hoarder.options.dump-dvb;
              }).optionsCommonMark;
            })
          ];
        }
      ];

      stop-box-modules = [
        {
          nixpkgs.overlays = [
            dump-dvb.overlays.default
          ];
        }
      ];

      # function that generates a system with the given number
      generate_system = (id: arch:
        {
          "traffic-stop-box-${toString id}" = nixpkgs.lib.nixosSystem {
            system = arch;
            specialArgs = inputs;
            modules = [
              # box-specific config
              ./hosts/traffic-stop-box/${toString id}.nix

              # default modules
              sops-nix.nixosModules.sops
              dump-dvb.nixosModules.default
              ./modules/traffic-stop-box
              ./modules/dump-dvb
              {
                deployment-dvb.systemNumber = id;
              }
            ] ++ stop-box-modules;
          };
        }
      );

      id_list = [
        {
          # Barkhausen Bau
          id = 0;
          arch = "x86_64-linux";
        }
        {
          # Zentralwerk
          id = 1;
          arch = "x86_64-linux";
        }
        {
          # Chemnitz
          id = 2;
          arch = "x86_64-linux";
        }
        {
          # unused
          id = 3;
          arch = "aarch64-linux";
        }
        {
          # Wundstr. 9
          id = 4;
          arch = "x86_64-linux";
        }
        {
          id = 6;
          arch = "x86_64-linux";
        }
        {
          id = 7;
          arch = "x86_64-linux";
        }
      ];

      # attribute set of all traffic stop boxes
      stop_boxes = nixpkgs.lib.foldl (x: y: nixpkgs.lib.mergeAttrs x (generate_system y.id y.arch)) { } id_list;

      packages = {
        default = self.nixosConfigurations.traffic-stop-box-0.config.system.build.vm;
        traffic-stop-box = self.nixosConfigurations.traffic-stop-box-0.config.system.build.vm;
        staging-data-hoarder = self.nixosConfigurations.staging-data-hoarder.config.system.build.vm;
        data-hoarder = self.nixosConfigurations.data-hoarder.config.system.build.vm;
        mobile-box-dresden-vm = self.nixosConfigurations.mobile-box-dresden.config.system.build.vm;
        mobile-box-dresden-disk = self.nixosConfigurations.mobile-box-dresden.config.system.build.diskImage;
        mobile-box-muenster-vm = self.nixosConfigurations.mobile-box-muenster.config.system.build.vm;
        mobile-box-muenster-disk = self.nixosConfigurations.mobile-box-muenster.config.system.build.diskImage;
        traffic-stop-box-7 = self.nixosConfigurations.traffic-stop-box-7.config.system.build.diskImage;
        staging-microvm = self.nixosConfigurations.staging-data-hoarder.config.microvm.declaredRunner;
        data-hoarder-microvm = self.nixosConfigurations.data-hoarder.config.microvm.declaredRunner;
        docs = pkgs.callPackage ./pkgs/documentation.nix {
          options-docs = (pkgs.nixosOptionsDoc {
            options = self.nixosConfigurations.data-hoarder.options.dump-dvb;
          }).optionsCommonMark;
        };
      } // (import ./pkgs/deployment.nix { inherit self pkgs; systems = stop_boxes; });

      mobile-box-modules = [
        dump-dvb.nixosModules.disk-module
        dump-dvb.nixosModules.default
        ./hosts/mobile-box/configuration.nix
        ./hosts/mobile-box/hardware-configuration.nix
        ./hardware/dell-wyse-3040.nix
        ./modules/base
        ./modules/user-stop-box/user.nix
        ./modules/dump-dvb
        sops-nix.nixosModules.sops
      ];
    in
    {
      packages."x86_64-linux" = packages;

      nixosConfigurations = stop_boxes // {
        mobile-box-dresden = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = inputs;
          modules = mobile-box-modules ++ [
            ./modules/mobile-box/dresden.nix
            {
              dump-dvb.telegramDecoder.configFile = "${self}/configs/mobile_box_dresden.json";
            }
          ];
        };
        mobile-box-muenster = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = inputs;
          modules = mobile-box-modules ++ [
            ./modules/mobile-box/muenster.nix
            {
              dump-dvb.telegramDecoder.configFile = "${self}/configs/mobile_box_muenster.json";
            }
          ];
        };

        data-hoarder = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = inputs;
          modules = [
            microvm.nixosModules.microvm
            ./hosts/data-hoarder/configuration.nix
          ] ++ data-hoarder-modules;
        };
        staging-data-hoarder = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = inputs;
          modules = [
            ./hosts/staging/configuration.nix
            microvm.nixosModules.microvm
            {
              environment.systemPackages = with pkgs; [ tcpdump ];
            }
          ] ++ data-hoarder-modules;
        };
        display = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = inputs;
          modules = [
            dump-dvb.nixosModules.default
            ./hosts/display
            ./modules/dump-dvb
            ./hardware/dell-wyse-3040.nix
          ];
        };
      };

      hydraJobs = (lib.mapAttrs (name: value: { ${value.config.system.build.toplevel.system} = value.config.system.build.toplevel; }) self.nixosConfigurations) // {
        display-disk."x86_64-linux" = self.nixosConfigurations.display.config.system.build.diskImage;
        sops-binaries."x86_64-linux" = sops-nix.packages."x86_64-linux".sops-install-secrets;
      };
    };
}
