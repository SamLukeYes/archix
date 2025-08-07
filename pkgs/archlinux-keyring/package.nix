{ lib
, stdenvNoCC
, fetchFromGitLab
, python3
, sequoia-sq
}:

stdenvNoCC.mkDerivation rec {
  pname = "archlinux-keyring";
  version = "20250807";

  src = fetchFromGitLab {
    domain = "gitlab.archlinux.org";
    owner = "archlinux";
    repo = pname;
    rev = version;
    hash = "sha256-7iMhj1iIrLOwzdcvw9cb4Nf/DOfUDR8k7W2M2mZuf+k=";
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