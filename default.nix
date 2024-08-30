{ pkgs ? import <nixpkgs> {} }:

with pkgs; {
  archlinux-keyring = callPackage ./pkgs/archlinux-keyring { };
  devtools = callPackage ./pkgs/devtools { };
  devtools-riscv64 = callPackage ./pkgs/devtools { enableRiscV = true; };
}