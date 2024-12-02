{ lib
, stdenvNoCC
, fetchFromGitLab
, python3
, sequoia-sq
}:

let
  sequoia-sq' = sequoia-sq.overrideAttrs (oldAttrs: rec {
    version = "0.38.0";
    src = fetchFromGitLab {
      owner = "sequoia-pgp";
      repo = "sequoia-sq";
      rev = "v${version}";
      hash = "sha256-Zzk7cQs5zD+houNjK8s3tP9kZ2/eAUV/OE3/GrNAXk8=";
    };

    # https://discourse.nixos.org/t/how-do-you-override-the-commit-rev-used-by-a-rust-package/47698/6
    cargoDeps = oldAttrs.cargoDeps.overrideAttrs {
      inherit src;
      outputHash = "sha256-BoLQfNZCfWyBASrLfKjBD3pyBDn33ede0ZORAc9JQ3c=";
    };
  });
in

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

  nativeBuildInputs = [ python3 sequoia-sq' ];

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