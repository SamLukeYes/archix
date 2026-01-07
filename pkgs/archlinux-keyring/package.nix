{ lib
, stdenvNoCC
, fetchFromGitLab
, python3
, sequoia-sq
}:

stdenvNoCC.mkDerivation rec {
  pname = "archlinux-keyring";
  version = "20260107";

  src = fetchFromGitLab {
    domain = "gitlab.archlinux.org";
    owner = "archlinux";
    repo = pname;
    rev = version;
    hash = "sha256-Ll/3bjHZyUnD159OGPxe41qpncaXjSU0KOU2i9XD2+k=";
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