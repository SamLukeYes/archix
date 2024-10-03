{
  description = "Utilities for Arch Linux development";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... } @inputs:
  let
    system = "x86_64-linux";
  in {
    packages.${system} = import ./. {
      pkgs = nixpkgs.legacyPackages.${system};
    };
    
    nixosModules = {
      default = { lib, ... }: {
        imports = [ self.nixosModules.pacman ];
        programs.pacman.enable = lib.mkDefault true;
      };
      
      pacman = import ./modules/pacman.nix self system;
    };
  };
}
