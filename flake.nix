{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-21.11;

    naersk = {
      url = github:nix-community/naersk;
      #inputs.nixpkgs.follows = "nixpkgs";
    };

    microvm = {
      url = github:astro/microvm.nix;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    radio-conf = {
      url = github:dump-dvb/radio-conf;
    };

    data-accumulator = {
      url = github:dump-dvb/data-accumulator;
    };

    decode-server = {
      url = github:dump-dvb/decode-server;
    };

    dvb-api = {
      url = github:dump-dvb/dvb-api;
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
    };

    clicky-bunty-server = {
      url = github:dump-dvb/clicky-bunty-server;
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
      # list of nixos systems
      list_of_systems = builtins.map generate_system id_list;
      # attribute set of all traffic stop boxes
      stop_boxes = nixpkgs.lib.foldr (x: y: nixpkgs.lib.mergeAttrs x y) { } list_of_systems;

      installScript = (target: (pkgs.writeScriptBin "deploy" ''
        #!${pkgs.runtimeShell}
        ssh root@10.13.37.${toString (target + 100)} "ps cax | grep \"nixos-rebuild\" > /dev/null"
        if [ $? -eq 0 ]
        then
            echo "Process is running."
            exit
        else
            echo "Process is not running."
            nix copy --to ssh://root@10.13.37.${toString (target + 100)} ${self}
            ssh root@10.13.37.${toString (target + 100)} -- nixos-rebuild switch --flake ${self} -L
        fi
      ''));

      # concatanes commands together
      deployBoxes = (systems: lib.strings.concatStringsSep " "
        (builtins.map (system: "${(installScript system)}/bin/deploy") systems));

      deployAllScript = (pkgs.writeScriptBin "deploy-all" (
        ''
          #!${pkgs.runtimeShell} -ex
          ${pkgs.parallel}/bin/parallel --will-cite -j10 ::: ${deployBoxes id_list} || echo "Some deployment failed"
        ''
      ));

      individualScripts = lib.foldl (x: y: lib.mergeAttrs x y) { } (builtins.map (number: { "deploy-box-${toString number}" = (installScript number); }) id_list);

      packages = {
        traffic-stop-box = self.nixosConfigurations.traffic-stop-box-0.config.system.build.vm;
        data-hoarder = self.nixosConfigurations.data-hoarder.config.system.build.vm;
        mobile-box-vm = self.nixosConfigurations.mobile-box.config.system.build.vm;
        mobile-box-disk = self.nixosConfigurations.mobile-box.config.system.build.diskImage;
        staging-microvm = self.nixosConfigurations.staging-data-hoarder.config.microvm.declaredRunner;
        deploy-all = deployAllScript;
      } // individualScripts;
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
