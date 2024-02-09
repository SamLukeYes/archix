{ lib
, stdenvNoCC
, fetchFromGitLab
, python3
, sequoia
}:

stdenvNoCC.mkDerivation rec {
  pname = "archlinux-keyring";
  version = "20240208";

  src = fetchFromGitLab {
    domain = "gitlab.archlinux.org";
    owner = "archlinux";
    repo = pname;

    # use a commit before sequoia-sq 0.33.0, since it is still 0.32.0 in nixpkgs
    rev = "34aa7efd3cc075ebb3164eb0e97b0f616ee426d4";
    hash = "sha256-s/Fc7NZhC/Fhe1zM6u9gv5ZwfvxscIAuyx9goDkhPj4=";
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