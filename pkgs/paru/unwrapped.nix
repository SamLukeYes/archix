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
  version = "2.0.3";

  src = fetchFromGitHub {
    owner = "Morganamilo";
    repo = "paru";
    rev = "v${version}";
    hash = "sha256-0+N1WkjHd2DREoS1pImXXvlJ3wXoXEBxFBtupjXqyP8=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = {
      "alpm-3.0.4" = "sha256-cfIOCUyb+kDAT3Bn50oKuJzIyMyeFyOPBFQMkAgMocI=";
      "aur-depends-3.0.0" = "sha256-Z/vCd4g3ic29vC0DXFHTT167xFAXYxzO2YQc0XQOerE=";
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