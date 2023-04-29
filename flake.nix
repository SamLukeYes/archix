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
    packages.${system} = with nixpkgs.legacyPackages.${system}; {
      archlinux-keyring = callPackage ./pkgs/archlinux-keyring { };
      asp = callPackage ./pkgs/asp { };
      devtools = callPackage ./pkgs/devtools { };
      devtools-riscv64 = callPackage ./pkgs/devtools { enableRiscV = true; };
      paru-unwrapped = callPackage ./pkgs/paru/unwrapped.nix { };
      paru = callPackage ./pkgs/paru {
        inherit (self.packages.${system}) asp devtools paru-unwrapped;
      };
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
