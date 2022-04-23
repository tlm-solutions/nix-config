{
  inputs = { 
    nixpkgs.url = github:NixOS/nixpkgs/nixos-21.11;

    sops-nix.url = github:Mic92/sops-nix;
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    naersk = {
      url = github:nix-community/naersk;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, sops-nix, naersk, ... }@inputs:
  let
  in {
    defaultPackage."x86_64-linux" = self.nixosConfigurations.traffic-stop-box.config.system.build.vm;

    nixosConfigurations = {
      traffic-stop-box = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/traffic-stop-box/configuration.nix
        ];
      };
    };
  };
}
