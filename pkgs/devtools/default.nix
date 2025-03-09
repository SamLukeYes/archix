{ lib
, stdenvNoCC
, fetchFromGitLab
, arch-install-scripts
, asciidoctor
, bash
, bat
, binutils
, breezy
, btrfs-progs
, coreutils
, curl
, debugedit
, diffutils
, fakeroot
, findutils
, gawk
, gettext
, git
, glibc
, gnugrep
, gnum4
, gnupg
, gnused
, gzip
, jq
, libarchive
, mercurial
, nvchecker
, openssh
, pacman
, parallel
, rsync
, subversion
, util-linux
}:

let
  path = lib.makeBinPath [
    "${placeholder "out"}"
    arch-install-scripts
    bash
    bat
    binutils
    breezy
    btrfs-progs
    coreutils
    debugedit
    diffutils
    fakeroot
    findutils
    gawk
    gettext
    git
    glibc
    gnugrep
    gnupg
    gnused
    gzip
    jq
    libarchive
    mercurial
    nvchecker
    openssh
    pacman
    parallel
    rsync
    subversion
    util-linux
  ];

in stdenvNoCC.mkDerivation rec {
  pname = "devtools";
  version = "1.3.2";

  src = fetchFromGitLab {
    domain = "gitlab.archlinux.org";
    owner = "archlinux";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-637YmCLIKq1jxfIwFIcv8wsriCeVXjKX6lkBYIEAw9Q=";
  };

  makeFlags = [ "PREFIX=$(out)" ];

  nativeBuildInputs = [ asciidoctor gnum4 ];

  buildInputs = [ bash ];   # make it possible to use a different bash version

  postPatch = ''
    for script in \
      ./src/lib/*.sh \
      ./src/lib/*/*.sh \
      ./src/*.in
    do
      substituteInPlace $script \
        --replace-warn "/usr/share/makepkg" "${pacman}/share/makepkg" \
        --replace-warn "/usr/share/devtools" "$out/share/devtools"
    done
    for conf in ./config/makepkg/*.conf; do
      substituteInPlace $conf \
        --replace-warn "/usr/bin/curl" "${curl}/bin/curl" \
        --replace-warn "/usr/bin/rsync" "${rsync}/bin/rsync" \
        --replace-warn "/usr/bin/scp" "${openssh}/bin/scp"
    done
    echo "export PATH=${path}:\$PATH" >> ./src/lib/common.sh
  '';

  meta = with lib; {
    description = "Tools for Arch Linux package maintainers";
    homepage = "https://gitlab.archlinux.org/archlinux/devtools";
    license = licenses.gpl3Plus;
    mainProgram = "pkgctl";
    platforms = [ "x86_64-linux" ];
  };
}