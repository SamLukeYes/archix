{ lib
, stdenvNoCC
, fetchFromGitLab
, python3
, sequoia-sq
}:

let
  sequoia-sq' = sequoia-sq.overrideAttrs (oldAttrs: rec {
    version = "0.39.0";
    src = fetchFromGitLab {
      owner = "sequoia-pgp";
      repo = "sequoia-sq";
      rev = "v${version}";
      hash = "sha256-nLrwf/4vbASOAyOWlc4X9ZQKFq/Kdh83XadpRuquEA4=";
    };

    # https://discourse.nixos.org/t/how-do-you-override-the-commit-rev-used-by-a-rust-package/47698/6
    cargoDeps = oldAttrs.cargoDeps.overrideAttrs {
      inherit src;
      name = "${oldAttrs.pname}-${version}-vendor.tar.gz";
      outputHash = "sha256-MnxvuO1KG7X2plFkQ/DNBHnH2cPi1X3SVbvcN8N7ZXk=";
    };
  });
in

stdenvNoCC.mkDerivation rec {
  pname = "archlinux-keyring";
  version = "20250123.1";

  src = fetchFromGitLab {
    domain = "gitlab.archlinux.org";
    owner = "archlinux";
    repo = pname;
    rev = version;
    hash = "sha256-XysXHAeefpY35L2UV4W8MtcEX5Do/FwBNO8J/2CNOiQ=";
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