{ lib
, stdenvNoCC
, bat
, devtools
, git
, gnupg
, makeWrapper
, pacman
, paru-unwrapped
}:

stdenvNoCC.mkDerivation {
  inherit (paru-unwrapped) version;
  pname = "paru";

  nativeBuildInputs = [ makeWrapper ];

  buildCommand = ''
    makeWrapper ${paru-unwrapped}/bin/paru $out/bin/paru \
      --prefix PATH : ${lib.makeBinPath [ bat devtools git gnupg pacman ]}
    ln -s ${paru-unwrapped}/{share,etc} $out
  '';

  passthru.unwrapped = paru-unwrapped;

  meta = paru-unwrapped.meta // {
    description = "Feature packed AUR helper";
  };
}