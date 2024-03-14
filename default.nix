{ pkgs ? import <nixpkgs> {} }:

with pkgs; rec {
  archlinux-keyring = callPackage ./pkgs/archlinux-keyring { };
  devtools = callPackage ./pkgs/devtools { };
  devtools-riscv64 = callPackage ./pkgs/devtools { enableRiscV = true; };
  paru-unwrapped = callPackage ./pkgs/paru/unwrapped.nix { };
  paru = callPackage ./pkgs/paru {
    inherit devtools paru-unwrapped;
  };
}