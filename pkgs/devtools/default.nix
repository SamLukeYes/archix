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

, substituteAll
, enableRiscV ? false
, archRiscVMirror ? "https://archriscv.felixc.at/repo"
}:

let
  system = stdenvNoCC.hostPlatform.system;

  carch = {
    x86_64-linux = "x86_64";
  }.${system} or (throw "Unsupported system: ${system}");

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
  version = "1.2.1";

  src = fetchFromGitLab {
    domain = "gitlab.archlinux.org";
    owner = "archlinux";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-j14Yl4l+e06p0OnnEaM33pz4PZTcHFbB0kdmVwJwxT0=";
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

  # TODO: ship sogrep-riscv64
  postInstall = lib.optionalString enableRiscV ''
    ln -s archbuild $out/bin/extra-riscv64-build
    patch $out/share/devtools/makepkg.conf.d/x86_64.conf \
      -i ${./riscv64-patches/makepkg.patch} \
      -o $out/share/devtools/makepkg.conf.d/riscv64.conf
    patch $out/share/devtools/pacman.conf.d/extra.conf \
      -i ${substituteAll {
        inherit archRiscVMirror;
        src = ./riscv64-patches/pacman.patch;
      }} \
      -o $out/share/devtools/pacman.conf.d/extra-riscv64.conf
    echo ${carch} > $out/share/devtools/setarch-aliases.d/riscv64
  '';

  meta = with lib; {
    # broken = enableRiscV;
    description = "Tools for Arch Linux package maintainers";
    homepage = "https://gitlab.archlinux.org/archlinux/devtools";
    license = licenses.gpl3Plus;
    mainProgram = "pkgctl";
    platforms = [ "x86_64-linux" ];
  };
}