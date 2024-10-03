{ pkgs ? import <nixpkgs> {} }:

with pkgs; {
  archlinux-keyring = callPackage ./pkgs/archlinux-keyring { };
  devtools = callPackage ./pkgs/devtools { };
}