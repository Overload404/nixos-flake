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
  {
    nixosConfigurations.overrig = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          # Use global nixpkgs for Home Manager
          home-manager.useGlobalPkgs = true;

          # Allow Home Manager to install user packages
          home-manager.useUserPackages = true;

          # Import the user's home configuration
          home-manager.users.overload = import ./home.nix;
        }
      ];
    };
  };
}
