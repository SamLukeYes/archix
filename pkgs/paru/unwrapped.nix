{ lib
, rustPlatform
, fetchFromGitHub
, gettext
, installShellFiles
, openssl
, pacman
, pkg-config
}:

rustPlatform.buildRustPackage rec {
  pname = "paru-unwrapped";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "Morganamilo";
    repo = "paru";
    rev = "v${version}";
    hash = "sha256-lCPrhSpH+ounBNm1hpr0dIimFQ/6ozJJfP/TXzkLmac=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = {
      "alpm-2.2.2" = "sha256-khUKX3OqNC6vpeSU0+IW9inwtnyARZVi+InFP4Lckz8=";
      "aur-depends-3.0.0" = "sha256-mvWuZ3FfDWwcijCCbuqNjP4mp/BbUCsHWwuVeIEUvOU=";
    };
  };

  # cargoHash = lib.fakeHash;

  postPatch = ''
    substituteInPlace src/lib.rs --replace "/usr/share" "$out/share"
    patchShebangs scripts/*
  '';

  nativeBuildInputs = [ gettext installShellFiles pkg-config ];

  buildInputs = [ openssl pacman ];

  postInstall = ''
    mkdir -p $out/etc $out/share
    cp paru.conf $out/etc/paru.conf
    
    installManPage man/*

    installShellCompletion --bash --name paru.bash completions/bash
    installShellCompletion --fish --name paru.fish completions/fish
    installShellCompletion --zsh --name _paru completions/zsh

    ./scripts/mkmo locale
    cp -r locale $out/share
  '';

  meta = with lib; {
    description = "Feature packed AUR helper (without runtime depends wrapped)";
    homepage = "https://github.com/Morganamilo/paru";
    license = licenses.gpl3Only;
  };
}