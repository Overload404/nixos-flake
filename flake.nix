{
  description = "NixOS configuration for overrig (AMD RDNA4 desktop)";

  inputs = {
    # NixOS unstable channel for latest packages and kernel
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager for declarative user environment
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    # Full NixOS system configuration (includes home-manager as a module)
    nixosConfigurations.overrig = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.overload = import ./home.nix;
        }
      ];
    };

    # Standalone Home Manager configuration (for home-manager switch --flake .#overload)
    homeConfigurations."overload" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [ ./home.nix ];
    };
  };
}
