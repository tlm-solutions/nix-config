{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

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

    private-flake-overlays = {
      url = "github:marenz2569/private-flake-overlays";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    ## TLMS stuff below
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
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    telegram-decoder = {
      url = "github:tlm-solutions/telegram-decoder";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        naersk.follows = "naersk";
        utils.follows = "flake-utils";
      };
    };

    r09-receiver = {
      url = "github:tlm-solutions/r09-receiver";
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
      inputs.utils.follows = "flake-utils";
    };
    borzoi = {
      url = "github:tlm-solutions/borzoi";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self
    , private-flake-overlays
    , borzoi
    , data-accumulator
    , datacare
    , funnel
    , r09-receiver
    , kindergarten
    , microvm
    , nixpkgs
    , sops-nix
    , lizard
    , bureaucrat
    , telegram-decoder
    , trekkie
    , chemo
    , nixos-hardware
    , ...
    }:
    let
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
      lib = pkgs.lib;
      overlayFlake = private-flake-overlays.lib.overlayFlake;

      registry = import ./registry;

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
          ];
        }
      ];

      stop-box-modules = [
        ./modules/TLMS
        telegram-decoder.nixosModules.default
        r09-receiver.nixosModules.default
        {
          nixpkgs.overlays = [
            telegram-decoder.overlays.default
            r09-receiver.overlays.default
          ];
        }
      ];

      # function that generates a system with the given number
      generate_system = (id:
        let
          myRegistry = registry.traffic-stop-box."${toString id}";
        in
        {
          "${myRegistry.hostName}" = {
            system = myRegistry.arch;
            specialArgs = { inherit self inputs; registry = myRegistry; };
            modules =
              [
                # box-specific config
                ./hosts/traffic-stop-box/${toString id}

                # default modules
                sops-nix.nixosModules.sops
                ./modules/traffic-stop-box
                ./modules/TLMS
                {
                  deployment-TLMS.monitoring.enable = myRegistry.monitoring;
                }
              ] ++ stop-box-modules;
          };
        }
      );

      # list of traffic-stop-box-$id that will be built
      stop_box_ids = [ 0 1 4 8 9 ];

      # attribute set of all traffic stop boxes
      r09_receivers = nixpkgs.lib.foldl (x: id: nixpkgs.lib.mergeAttrs x (generate_system id)) { } stop_box_ids;

      unevaluatedNixosConfigurations = r09_receivers // {
        data-hoarder = {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; registry = registry.data-hoarder; };
          modules = [
            microvm.nixosModules.microvm
            ./hosts/data-hoarder
          ] ++ data-hoarder-modules;
        };

        staging-data-hoarder = {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; registry = registry.staging-data-hoarder; };
          modules = [
            ./hosts/staging-data-hoarder
            microvm.nixosModules.microvm
          ] ++ data-hoarder-modules;
        };

        notice-me-senpai = {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; registry = registry.notice-me-senpai; };
          modules = [
            sops-nix.nixosModules.sops
            microvm.nixosModules.microvm
            ./modules/TLMS
            ./hosts/notice-me-senpai
          ];
        };

        tram-borzoi = {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; registry = registry.tram-borzoi; };
          modules = [
            sops-nix.nixosModules.sops
            microvm.nixosModules.microvm

            borzoi.nixosModules.default
            { nixpkgs.overlays = [ borzoi.overlays.default ]; }

            ./modules/TLMS
            ./hosts/tram-borzoi
          ];
        };

        tetra-zw = {
          system = "x86_64-linux";
          specialArgs = { inherit inputs self; registry = registry.tetra-zw; };
          modules = [
            sops-nix.nixosModules.sops
            nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen1

            ./modules/TLMS
            ./hosts/tetra-zw
          ];
        };

        uranus = {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs self;
            registry = registry.uranus;
            bind-ip = registry.uranus.wgAddr4;
          };
          modules = [
            sops-nix.nixosModules.sops
            microvm.nixosModules.microvm

            ./modules/TLMS
            ./hosts/uranus
          ];
        };
      };
    in
    # overlays this private flake when in impure mode
    overlayFlake "git+ssh://git@github.com/tlm-solutions/nix-config-private.git" {
      inherit unevaluatedNixosConfigurations;

      packages."aarch64-linux".box8 = self.nixosConfigurations.traffic-stop-box-8.config.system.build.sdImage;
      packages."aarch64-linux".box9 = self.nixosConfigurations.traffic-stop-box-9.config.system.build.sdImage;

      packages."x86_64-linux" = {
        staging-microvm = self.nixosConfigurations.staging-data-hoarder.config.microvm.declaredRunner;
        data-hoarder-microvm = self.nixosConfigurations.data-hoarder.config.microvm.declaredRunner;
      };

      # these are in the app declaration as nix before 2.19 tries to find attrPaths in packages first.
      # here we evaluate over all nixos configurations making this extremely slow
      apps."x86_64-linux" = (import ./pkgs/deployment.nix { inherit self pkgs lib; });

      nixosConfigurations = lib.attrsets.mapAttrs (name: value: (nixpkgs.lib.nixosSystem value)) unevaluatedNixosConfigurations;

      hydraJobs =
        let
          get-toplevel = (host: nixSystem: nixSystem.config.microvm.declaredRunner or nixSystem.config.system.build.toplevel);
        in
        nixpkgs.lib.mapAttrs get-toplevel self.nixosConfigurations;
    };
}
