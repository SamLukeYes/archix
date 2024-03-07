{ pkgs ? import <nixpkgs> {} }:

with pkgs; rec {
  archlinux-keyring = callPackage ./pkgs/archlinux-keyring { };
  devtools = callPackage ./pkgs/devtools { };
  devtools-riscv64 = callPackage ./pkgs/devtools { enableRiscV = true; };
  paru-unwrapped = callPackage ./pkgs/paru/unwrapped.nix {
    pacman = pacman.overrideAttrs (old: rec {
      version = "6.0.2";    # libalpm 13
      src = fetchurl {
        url = "https://sources.archlinux.org/other/${old.pname}/${old.pname}-${version}.tar.xz";
        hash = "sha256-fY4+jFEhrsCWXfcfWb7fRgUsbPFPljZcRBHsPeCkwaU=";
      };
    });
  };
  paru = callPackage ./pkgs/paru {
    inherit devtools paru-unwrapped;
  };
}