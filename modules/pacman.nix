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
          default = "${self.packages.${system}.devtools}/share/devtools/pacman.conf.d/multilib.conf";
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
            Additional config to be included by `/etc/pacman.conf`.
          '';
        };
      };
      confMode = lib.mkOption {
        type = lib.types.str;
        default = "symlink";
        example = "0644";
        description = lib.mdDoc ''
          The default mode of pacman configuration files.
        '';
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
        default = "${self.packages.${system}.devtools}/share/devtools/makepkg.conf.d/x86_64.conf";
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
        "makepkg.conf" = {
          mode = lib.mkDefault cfg.confMode;
          source = cfg.makepkg.conf.source;
        };
        "pacman.conf" = {
          mode = lib.mkDefault cfg.confMode;
          source = pkgs.runCommand "pacman.conf" { } ''
            cp ${cfg.conf.source} $out
            substituteInPlace $out --replace "NoProgressBar" "#NoProgressBar"
            cat <<EOF >> $out

            # programs.pacman.conf.extraConfig
            Include = /etc/pacman.d/extra.conf
            EOF
          '';
        };
        "pacman.d/extra.conf" = {
          mode = lib.mkDefault cfg.confMode;
          text = cfg.conf.extraConfig;
        };
        "pacman.d/mirrorlist" = {
          mode = lib.mkDefault cfg.confMode;
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