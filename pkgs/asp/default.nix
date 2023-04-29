{ lib
, resholve
, fetchFromGitHub
, bash
, asciidoc
, coreutils
, curl
, gawk
, git
, gnum4
, gnutar
, jq
}:

resholve.mkDerivation rec {
  pname = "asp";
  version = "8";

  src = fetchFromGitHub {
    owner = "archlinux";
    repo = "asp";
    rev = "v${version}";
    sha256 = "sha256-UuWdWu+tBLm/Tf4gC0UUcVcx3vQ+Gp359U+qV8CAH54=";
  };

  nativeBuildInputs = [ asciidoc gnum4 ];

  installFlags = [ "PREFIX=$(out)" ];

  solutions.profile = {
    scripts = [ "bin/asp" ];
    interpreter = "${bash}/bin/bash";
    inputs = [ coreutils curl gawk git gnutar jq ];
    keep = [ "$dumpfn" "$candidates" ];
    execer = [ "cannot:${git}/bin/git" ];
  };

  meta = with lib; {
    description = "Arch Linux build source file management tool";
    homepage = "https://github.com/archlinux/asp";
    license = licenses.mit;
  };
}