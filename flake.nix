{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";

    # naersk and flake utils are not used by this flake directly, but needed
    # for the follows in all the other ones.
    naersk = {
      url = "github:nix-community/naersk";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # DO NOT remame this to utils
    flake-utils.url = "github:numtide/flake-utils";

    microvm = {
      url = "github:astro/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
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
        utils.follows = "flake-utils";
      };
    };

    datacare = {
      url = "github:tlm-solutions/datacare";
    };

    kindergarten = {
      url = "github:tlm-solutions/kindergarten";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };

    telegram-decoder = {
      url = "github:tlm-solutions/telegram-decoder";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        naersk.follows = "naersk";
        utils.follows = "flake-utils";
      };
    };

    gnuradio-decoder = {
      url = "github:tlm-solutions/gnuradio-decoder";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };

    data-accumulator = {
      url = "github:tlm-solutions/data-accumulator";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.naersk.follows = "naersk";
      inputs.utils.follows = "flake-utils";
    };

    lizard = {
      url = "github:tlm-solutions/lizard";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };

    bureaucrat = {
      url = "github:tlm-solutions/bureaucrat";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };

    funnel = {
      url = "github:tlm-solutions/funnel";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };

    tlms-rs = {
      url = "github:tlm-solutions/tlms.rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    chemo = {
      url = "github:tlm-solutions/chemo";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    borzoi = {
      url = "github:tlm-solutions/borzoi";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self
    , borzoi
    , data-accumulator
    , datacare
    , documentation-src
    , funnel
    , gnuradio-decoder
    , kindergarten
    , microvm
    , nixpkgs
    , sops-nix
    , lizard
    , bureaucrat
    , telegram-decoder
    , trekkie
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
        lizard.nixosModules.default
        bureaucrat.nixosModules.default
        trekkie.nixosModules.default
        chemo.nixosModules.default
        {
          nixpkgs.overlays = [
            datacare.overlays.default
            kindergarten.overlays.default
            trekkie.overlays.default
            lizard.overlays.default
            bureaucrat.overlays.default
            funnel.overlays.default
            data-accumulator.overlays.default
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
      generate_system = (id: arch: monitoring:
        {
          "traffic-stop-box-${toString id}" = nixpkgs.lib.nixosSystem
            {
              system = arch;
              specialArgs = inputs;
              modules =
                let
                  monitoring-mod =
                    if monitoring
                    then { deployment-TLMS.monitoring.enable = true; }
                    else { deployment-TLMS.monitoring.enable = false; };
                in
                [
                  # box-specific config
                  ./hosts/traffic-stop-box/${toString id}

                  # default modules
                  sops-nix.nixosModules.sops
                  ./modules/traffic-stop-box
                  ./modules/TLMS
                  {
                    deployment-TLMS.systemNumber = id;
                  }
                  monitoring-mod
                ] ++ stop-box-modules;
            };
        }
      );

      id_list = [
        {
          # Barkhausen Bau
          id = 0;
          arch = "x86_64-linux";
          monitoring = true;
        }
        {
          # Zentralwerk
          id = 1;
          arch = "x86_64-linux";
          monitoring = true;
        }
        # {
        #   # Chemnitz
        #   id = 2;
        #   arch = "x86_64-linux";
        #   monitoring = false;
        # }
        {
          # Wundstr. 9
          id = 4;
          arch = "x86_64-linux";
          monitoring = true;
        }
        {
          # Warpzone
          id = 6;
          arch = "x86_64-linux";
          monitoring = true;
        }
      ];

      # attribute set of all traffic stop boxes
      stop_boxes = nixpkgs.lib.foldl (x: y: nixpkgs.lib.mergeAttrs x (generate_system y.id y.arch y.monitoring)) { } id_list;

      packages = {
        staging-microvm = self.nixosConfigurations.staging-data-hoarder.config.microvm.declaredRunner;
        borken-microvm = self.nixosConfigurations.borken-data-hoarder.config.microvm.declaredRunner;
        data-hoarder-microvm = self.nixosConfigurations.data-hoarder.config.microvm.declaredRunner;
        docs = pkgs.callPackage ./pkgs/documentation.nix {
          inherit documentation-src;
          options-docs = (pkgs.nixosOptionsDoc {
            options = self.nixosConfigurations.data-hoarder.options.TLMS;
          }).optionsCommonMark;
        };
      }
      // (import ./pkgs/deployment.nix { inherit self pkgs lib;})
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

        borken-data-hoarder = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            ./hosts/borken-data-hoarder
            microvm.nixosModules.microvm
          ] ++ data-hoarder-modules;
        };

        notice-me-senpai = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            sops-nix.nixosModules.sops
            ./modules/TLMS
            ./hosts/notice-me-senpai
          ];
        };

        tram-borzoi = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            sops-nix.nixosModules.sops
            microvm.nixosModules.microvm

            borzoi.nixosModules.default
            { nixpkgs.overlays = [ borzoi.overlays.default ]; }

            ./modules/TLMS
            ./hosts/tram-borzoi
          ];
        };

        uranus = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            sops-nix.nixosModules.sops
            microvm.nixosModules.microvm

            ./modules/TLMS
            ./hosts/uranus
          ];
        };

      };
      apps."x86_64-linux".mctest = {
        type = "app";
        program = "${self.packages."x86_64-linux".test-vm-wrapper}";
      };

      nixosModules."x86_64-linux".watch-me-senpai = import ./modules/watch-me-senpai;

      hydraJobs =
        let
          get-toplevel = (host: nixSystem: nixSystem.config.microvm.declaredRunner or nixSystem.config.system.build.toplevel);
        in
        nixpkgs.lib.mapAttrs get-toplevel self.nixosConfigurations;
      };
}
