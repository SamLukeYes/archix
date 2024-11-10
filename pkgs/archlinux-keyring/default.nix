{ lib
, stdenvNoCC
, fetchFromGitLab
, fetchpatch
, python3
, sequoia
}:

stdenvNoCC.mkDerivation rec {
  pname = "archlinux-keyring";
  version = "20241015";

  src = fetchFromGitLab {
    domain = "gitlab.archlinux.org";
    owner = "archlinux";
    repo = pname;
    rev = version;
    hash = "sha256-KGicvhppPVFQpULq+G0CMjwtqzzo02Mt3dWNOTzPE2s=";
  };

  patches = [
    # fix: Adapt use of sq to sequoia-sq 0.39.0
    (fetchpatch {
      url = "https://gitlab.archlinux.org/archlinux/archlinux-keyring/-/commit/1b5d2bddcd847c0dc05ac4899867f2c76a8838b8.patch";
      hash = "sha256-yx4P2Yb2U5Q4fdGMXcVQZhnnn1griUkHTkXCBOIPr9s=";
    })
  ];

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