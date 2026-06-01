{ ... }:
{
  imports = [
    ./boot.nix
    ./hardware.nix
    ./services.nix
    ./packages.nix
    ./users.nix
    ./programs.nix
  ];
}
