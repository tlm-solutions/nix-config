{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";

    # naersk and flake utils are not used by this flake directly, but needed
    # for the follows in all the other ones.
    naersk = {
      url = "github:nix-community/naersk";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    microvm = {
      url = "github:astro/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ## TLMS stuff below
    documentation-src = {
      url = "github:tlm-solutions/documentation";
      flake = false;
    };

    trekkie = {
      url = "github:tlm-solutions/trekkie";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        naersk.follows = "naersk";
        tlms-rs.follows = "tlms-rs";
      };
    };

    datacare = {
      url = "github:tlm-solutions/datacare";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        naersk.follows = "naersk";
        tlms-rs.follows = "tlms-rs";
      };
    };

    kindergarten = {
      url = "github:tlm-solutions/kindergarten";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    telegram-decoder = {
      url = "github:tlm-solutions/telegram-decoder";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        naersk.follows = "naersk";
      };
    };

    gnuradio-decoder = {
      url = "github:tlm-solutions/gnuradio-decoder";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    data-accumulator = {
      url = "github:tlm-solutions/data-accumulator";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.naersk.follows = "naersk";
    };

    state-api = {
      url = "github:tlm-solutions/state-api";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.naersk.follows = "naersk";
    };

    funnel = {
      url = "github:tlm-solutions/funnel";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    windshield = {
      url = "github:tlm-solutions/windshield";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wartrammer = {
      url = "github:tlm-solutions/wartrammer-40k";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.naersk.follows = "naersk";
    };

    tlms-rs = {
      url = "github:tlm-solutions/tlms.rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    chemo = {
      url = "github:tlm-solutions/chemo";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self
    , data-accumulator
    , datacare
    , documentation-src
    , funnel
    , gnuradio-decoder
    , kindergarten
    , microvm
    , nixpkgs
    , sops-nix
    , state-api
    , telegram-decoder
    , trekkie
    , wartrammer
    , windshield
    , chemo
    , ...
    }:
    let
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
      lib = pkgs.lib;


      data-hoarder-modules = [
        ./modules/data-hoarder
        ./modules/TLMS
        data-accumulator.nixosModules.default
        datacare.nixosModules.default
        funnel.nixosModules.default
        sops-nix.nixosModules.sops
        state-api.nixosModules.default
        trekkie.nixosModules.default
        chemo.nixosModules.default
        {
          nixpkgs.overlays = [
            datacare.overlays.default
            kindergarten.overlays.default
            trekkie.overlays.default
            state-api.overlays.default
            funnel.overlays.default
            data-accumulator.overlays.default
            windshield.overlays.default
            chemo.overlays.default
            (final: prev: {
              inherit documentation-src;
              options-docs = (pkgs.nixosOptionsDoc {
                options = self.nixosConfigurations.data-hoarder.options.TLMS;
              }).optionsCommonMark;
            })
          ];
        }
      ];

      stop-box-modules = [
        ./modules/TLMS
        telegram-decoder.nixosModules.default
        gnuradio-decoder.nixosModules.default
        {
          nixpkgs.overlays = [
            telegram-decoder.overlays.default
            gnuradio-decoder.overlays.default
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
              ./modules/traffic-stop-box
              ./modules/TLMS
              {
                deployment-TLMS.systemNumber = id;
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
        {
          id = 10;
          arch = "x86_64-linux";
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
            options = self.nixosConfigurations.data-hoarder.options.TLMS;
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
          specialArgs = { inherit inputs self; };
          modules = [
            microvm.nixosModules.microvm
            ./hosts/data-hoarder
          ] ++ data-hoarder-modules;
        };

        staging-data-hoarder = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            ./hosts/staging-data-hoarder
            microvm.nixosModules.microvm
          ] ++ data-hoarder-modules;
        };
      };

      nixosModules."x86_64-linux".watch-me-senpai = import ./modules/watch-me-senpai;

      hydraJobs = (lib.mapAttrs (_name: value: { ${value.config.system.build.toplevel.system} = value.config.system.build.toplevel; }) self.nixosConfigurations) // {
        sops-binaries."x86_64-linux" = sops-nix.packages."x86_64-linux".sops-install-secrets;
      };
    };
}
