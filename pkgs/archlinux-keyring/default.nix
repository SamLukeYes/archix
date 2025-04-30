{ lib
, stdenvNoCC
, fetchFromGitLab
, python3
, sequoia-sq
}:

stdenvNoCC.mkDerivation rec {
  pname = "archlinux-keyring";
  version = "20250430";

  src = fetchFromGitLab {
    domain = "gitlab.archlinux.org";
    owner = "archlinux";
    repo = pname;
    rev = version;
    hash = "sha256-+7gVql5nSQI7hZXi7mW7KxuYSuyUcbwQU3ubFAFKM4s=";
  };

  nativeBuildInputs = [ python3 sequoia-sq ];

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