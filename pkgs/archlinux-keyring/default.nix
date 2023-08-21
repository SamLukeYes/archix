{ lib
, stdenvNoCC
, fetchzip
, python3
, sequoia
}:

stdenvNoCC.mkDerivation rec {
  pname = "archlinux-keyring";
  version = "20230821";

  src = fetchzip {
    url = "https://gitlab.archlinux.org/archlinux/${pname}/-/archive/${version}/${pname}-${version}.tar.gz";
    hash = "sha256-sLyR6Aa2dkgk6Ceo/VVQsGUcvDc3WTgCZQM0tqNaXwA=";
  };

  nativeBuildInputs = [ python3 sequoia ];

  makeFlags = [ "PREFIX=$(out)" ];

  postPatch = ''
    patchShebangs ./keyringctl
  '';

  installPhase = ''
    runHook preInstall
    install -vDm 644 build/{archlinux.gpg,archlinux-revoked,archlinux-trusted} \
      -t $out/
    runHook postInstall
  '';

  meta = with lib; {
    description = "Arch Linux PGP keyring";
    homepage = "https://gitlab.archlinux.org/archlinux/archlinux-keyring/";
    license = licenses.gpl3Plus;
  };
}