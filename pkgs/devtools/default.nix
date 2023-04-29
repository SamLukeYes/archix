{ lib
, stdenv
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
  path = lib.makeBinPath [
    "${placeholder "out"}"
    arch-install-scripts
    bash
    binutils
    breezy
    btrfs-progs
    coreutils
    diffutils
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

in stdenv.mkDerivation rec {
  pname = "devtools";
  version = "20230307";

  src = fetchzip {
    url = "https://gitlab.archlinux.org/archlinux/devtools/-/archive/${version}/devtools-${version}.zip";
    hash = "sha256-yGBsmjb3iNYsUX7i2+kPY25Zp/Nfbl/7/sLCmokBelE=";
  };

  makeFlags = [ "PREFIX=$(out)" ];

  nativeBuildInputs = [ asciidoc gnum4 ];

  buildInputs = [ bash ];   # make it possible to use a different bash version

  postPatch = ''
    for script in \
      ./lib/common.sh \
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
    echo "export PATH=${path}:\$PATH" >> ./lib/common.sh
  '';

  # TODO: ship sogrep-riscv64
  postInstall = lib.optionalString enableRiscV ''
    ln -s archbuild $out/bin/extra-riscv64-build
    patch $out/share/devtools/makepkg-x86_64.conf \
      -i ${./riscv64-patches/makepkg.patch} \
      -o $out/share/devtools/makepkg-riscv64.conf
    patch $out/share/devtools/pacman-extra.conf \
      -i ${substituteAll {
        inherit archRiscVMirror;
        src = ./riscv64-patches/pacman.patch;
      }} \
      -o $out/share/devtools/pacman-extra-riscv64.conf
    echo x86_64 > $out/share/devtools/setarch-aliases.d/riscv64
  '';

  meta = with lib; {
    description = "Tools for Arch Linux package maintainers";
    homepage = "https://gitlab.archlinux.org/archlinux/devtools";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}