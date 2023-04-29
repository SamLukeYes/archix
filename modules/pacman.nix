self: system: { config, lib, pkgs, ... }:

let
  cfg = config.programs.pacman;
  keyrings = pkgs.symlinkJoin {
    name = "pacman-keyrings";
    paths = cfg.keyrings;
  };

in {
  options = {
    programs.pacman = {
      enable = lib.mkEnableOption "pacman";
      autoSync = {
        enable = lib.mkEnableOption "automatically sync pacman databases";
        dates = lib.mkOption {
          type = lib.types.str;
          default = "daily";
          description = lib.mdDoc ''
            How often and when to perform automatic syncs.

            The format is described in
            {manpage}`systemd.time(7)`.
          '';
        };
      };
      conf = {
        source = lib.mkOption {
          type = lib.types.path;
          default = "${self.packages.${system}.devtools}/share/devtools/pacman-multilib.conf";
          description = lib.mdDoc ''
            The source of `/etc/pacman.conf`.
          '';
        };
        extraConfig = lib.mkOption {
          type = lib.types.lines;
          default = "";
          example = ''
            [options]
            Color

            [arch4edu]
            Server = https://m.mirrorz.org/$repo/$arch
            
            [custom]
            SigLevel = Optional TrustAll
            Server = file:///home/custompkgs
          '';
          description = lib.mdDoc ''
            Additional text to be added to `/etc/pacman.conf`.
          '';
        };
      };
      keyrings = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ self.packages.${system}.archlinux-keyring ];
        description = lib.mdDoc ''
          List of keyring packages to be trusted by pacman.
        '';
      };
      makepkg.conf.source = lib.mkOption {
        type = lib.types.path;
        default = "${self.packages.${system}.devtools}/share/devtools/makepkg-x86_64.conf";
        description = lib.mdDoc ''
          The source of `/etc/makepkg.conf`.
        '';
      };
      mirrors = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "https://geo.mirror.pkgbuild.com/$repo/os/$arch" ];
        description = lib.mdDoc ''
          List of mirrors in `/etc/pacman.d/mirrorlist`.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment = {
      etc = {
        "makepkg.conf".source = cfg.makepkg.conf.source;
        "pacman.conf".source = pkgs.runCommand "pacman.conf" { } ''
          cp ${cfg.conf.source} $out
          substituteInPlace $out --replace "NoProgressBar" "#NoProgressBar"
          cat >> $out << EOF
          
          # programs.pacman.conf.extraConfig
          ${cfg.conf.extraConfig}
          EOF
        '';
        "pacman.d/mirrorlist" = {
          mode = "0644";    # Allow editing
          text = ''
            Server = ${lib.concatStringsSep "\nServer = " cfg.mirrors}
          '';
        };
      };
      systemPackages = [ pkgs.pacman ];
    };
    
    systemd = {
      services = {
        pacman-init = lib.mkIf (cfg.keyrings != []) {
          path = [ pkgs.pacman ];
          script = ''
            export KEYRING_IMPORT_DIR=${keyrings}
            pacman-key --init
            pacman-key --populate
          '';
          serviceConfig = {
            RemainAfterExit = true;
            Type = "oneshot";
          };
          wantedBy = [ "multi-user.target" ];
        };
        pacman-sync = lib.mkIf cfg.autoSync.enable {
          path = [ pkgs.pacman ];
          requires = [ "network-online.target" ];
          script = ''
            pacman -Sy
            pacman -Fy
          '';
          serviceConfig.Type = "oneshot";
          startAt = cfg.autoSync.dates;
        };
      };
      tmpfiles.rules = [
        "d /var/lib/pacman 1755 root root -"
        "d /var/cache/pacman 1755 root root 30d"
        # TODO: use paccache to clean up instead of tmpfiles
      ];
    };
  };
}