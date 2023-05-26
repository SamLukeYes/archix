{ lib
, stdenvNoCC
, fetchzip
, arch-install-scripts
, asciidoc
, bash
, binutils
, breezy
, btrfs-progs
, coreutils
, curl
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
, libarchive
, mercurial
, openssh
, pacman
, rsync
, subversion
, systemd
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
    binutils
    breezy
    btrfs-progs
    coreutils
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
    libarchive
    mercurial
    openssh
    pacman
    rsync
    subversion
    systemd
    util-linux
  ];

in stdenvNoCC.mkDerivation rec {
  pname = "devtools";
  version = "1.0.1";

  src = fetchzip {
    url = "https://gitlab.archlinux.org/archlinux/devtools/-/archive/v${version}/devtools-v${version}.zip";
    hash = "sha256-zTSorhJkxTPVXCES+PGz4fD50jH+WZzPfe+ZAYZ9Aa4=";
  };

  makeFlags = [ "PREFIX=$(out)" ];

  nativeBuildInputs = [ asciidoc gnum4 ];

  buildInputs = [ bash ];   # make it possible to use a different bash version

  postPatch = ''
    for script in \
      ./src/lib/common.sh \
      ./src/lib/release.sh \
      ./src/lib/build/build.sh \
      ./src/lib/repo/clone.sh \
      ./src/lib/repo/configure.sh \
      ./src/lib/repo/switch.sh \
      ./src/lib/version/version.sh \
      ./src/makechrootpkg.in \
      ./src/makerepropkg.in \
      ./src/offload-build.in \
      ./src/sogrep.in
    do
      substituteInPlace $script \
        --replace "/usr/share/makepkg" "${pacman}/share/makepkg" \
        --replace "/usr/share/devtools" "$out/share/devtools"
    done
    for conf in ./config/makepkg/*.conf; do
      substituteInPlace $conf \
        --replace "/usr/bin/curl" "${curl}/bin/curl" \
        --replace "/usr/bin/rsync" "${rsync}/bin/rsync" \
        --replace "/usr/bin/scp" "${openssh}/bin/scp"
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
    description = "Tools for Arch Linux package maintainers";
    homepage = "https://gitlab.archlinux.org/archlinux/devtools";
    license = licenses.gpl3Plus;
    mainProgram = "pkgctl";
    platforms = [ "x86_64-linux" ];
  };
}