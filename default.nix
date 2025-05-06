{ pkgs ? import <nixpkgs> {} }:

with pkgs;
lib.packagesFromDirectoryRecursive {
  inherit callPackage;
  directory = ./pkgs;
}