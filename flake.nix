{
  description = "Utilities for Arch Linux development";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    xddxdd = {
      url = "github:xddxdd/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... } @inputs:
  let
    system = "x86_64-linux";
  in {
    packages.${system} = import ./. {
      pkgs = nixpkgs.legacyPackages.${system};
    };
    overlays.qemu = final: prev: {
      qemu-user-static = inputs.xddxdd.packages.${system}.qemu-user-static;
    };
    nixosModules = {
      default = { lib, ... }: {
        imports = [ self.nixosModules.pacman ];
        programs.pacman.enable = lib.mkDefault true;
      };
      binfmt = {
        imports = [ inputs.xddxdd.nixosModules.qemu-user-static-binfmt ];
        nixpkgs.overlays = [ self.overlays.qemu ];
      };
      pacman = import ./modules/pacman.nix self system;
    };
  };
}
