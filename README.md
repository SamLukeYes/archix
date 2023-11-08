# Archix
Utilities for Arch Linux development, in a flake.

### Available packages related to Arch Linux
- Nixpkgs
    - pacman
    - arch-install-scripts
- Archix
    - archlinux-keyring
    - ~~asp~~ (deprecated)
    - devtools
    - paru

### Things missing
- pacman-contrib
- namcap
- NixOS module to set up paru for chroot build

### Setup
`pacman` and its dependents may expect the existence of valid `/etc/pacman.conf`, `/etc/pacman.d/mirrorlist` and `/etc/makepkg.conf`, so you need to set them up before running any programs in this flake. If you manage your NixOS configuration with flakes, you can use the Archix modules for an easy setup:

```nix
# Add the followings to flake.nix
{
    inputs.archix.url = "github:SamLukeYes/archix";
    outputs = { ... }@inputs:
    {
        nixosConfigurations.your-hostname = {
            modules = [
                inputs.archix.nixosModules.default
            ];
        };
    };
}
```

Then you can use the utilities in this flake, e.g.
```command
$ nix shell "github:SamLukeYes/archix#devtools" -c extra-x86_64-build
```

### License
GPL-3.0 or later