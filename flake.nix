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

    nixpkgs.url = github:NixOS/nixpkgs/nixos-22.11;

    sops-nix = {
      url = github:Mic92/sops-nix;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    documentation-src = {
      url = github:dump-dvb/documentation;
      flake = false;
    };
  };

  outputs =
    inputs@{ self
    , dump-dvb
    , microvm
    , nixpkgs
    , sops-nix
    , documentation-src
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
            (final: prev: {
              inherit documentation-src;
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
              ./hosts/traffic-stop-box/${toString id}

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
          # Warpzone
          id = 6;
          arch = "x86_64-linux";
        }
        {
          id = 7;
          arch = "x86_64-linux";
        }
        {
          id = 8;
          arch = "aarch64-linux";
        }
        {
          id = 9;
          arch = "aarch64-linux";
        }
      ];

      # attribute set of all traffic stop boxes
      stop_boxes = nixpkgs.lib.foldl (x: y: nixpkgs.lib.mergeAttrs x (generate_system y.id y.arch)) { } id_list;

      packages = {
        staging-microvm = self.nixosConfigurations.staging-data-hoarder.config.microvm.declaredRunner;
        data-hoarder-microvm = self.nixosConfigurations.data-hoarder.config.microvm.declaredRunner;
        docs = pkgs.callPackage ./pkgs/documentation.nix {
          inherit documentation-src;
          options-docs = (pkgs.nixosOptionsDoc {
            options = self.nixosConfigurations.data-hoarder.options.dump-dvb;
          }).optionsCommonMark;
        };
      }
      // (import ./pkgs/deployment.nix { inherit self pkgs; systems = stop_boxes; })
      // (lib.foldl (x: y: lib.mergeAttrs x { "${y.config.system.name}-vm" = y.config.system.build.vm; }) { } (lib.attrValues self.nixosConfigurations));

    in
    {
      packages."x86_64-linux" = packages;

      nixosConfigurations = stop_boxes // {

        data-hoarder = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = inputs;
          modules = [
            microvm.nixosModules.microvm
            ./hosts/data-hoarder
          ] ++ data-hoarder-modules;
        };

        staging-data-hoarder = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = inputs;
          modules = [
            ./hosts/staging-data-hoarder
            microvm.nixosModules.microvm
          ] ++ data-hoarder-modules;
        };
        watch-me-senpai = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = inputs;
          modules = [
            ./modules/dump-dvb
            ./hosts/watch-me-senpai
            ./modules/watch-me-senpai/secrets.nix
            microvm.nixosModules.microvm
            sops-nix.nixosModules.sops
            dump-dvb.nixosModules.default
            {
              nixpkgs.overlays = [
                dump-dvb.overlays.default
              ];
            }
          ];
        };
      };

      hydraJobs = (lib.mapAttrs (_name: value: { ${value.config.system.build.toplevel.system} = value.config.system.build.toplevel; }) self.nixosConfigurations) // {
        sops-binaries."x86_64-linux" = sops-nix.packages."x86_64-linux".sops-install-secrets;
      };
    };
}
