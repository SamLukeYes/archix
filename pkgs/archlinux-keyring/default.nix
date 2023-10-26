{ lib
, stdenvNoCC
, fetchurl
, python3
, sequoia
}:

stdenvNoCC.mkDerivation rec {
  pname = "archlinux-keyring";
  version = "20231026";

  src = fetchurl {
    url = "https://gitlab.archlinux.org/archlinux/${pname}/-/archive/${version}/${pname}-${version}.tar.gz";
    hash = "sha256:0ae2ef69031f0634af8f381ede600c7f89bee3f70d9763fadd1c6da2222acc8e";
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