{ lib
, stdenvNoCC
, fetchurl
, python3
, sequoia
}:

stdenvNoCC.mkDerivation rec {
  pname = "archlinux-keyring";
  version = "20231113";

  src = fetchurl {
    url = "https://gitlab.archlinux.org/archlinux/${pname}/-/archive/${version}/${pname}-${version}.tar.gz";
    hash = "sha256:363d2579e9c09ad15faf9456d84957100acc0239ffeb1ac1602a3322a33c3823";
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