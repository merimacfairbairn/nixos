{
  self,
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.niri = moduleWithSystem ({self', ...}: let
    modules = with self.nixosModules; [
      audio
    ];
  in {
    imports = modules;
    programs.niri = {
      enable = true;
      package = self'.packages.niri;
    };

    services.displayManager.noctalia-greeter = {
      enable = true;

      settings = {
        keyboard.layout = "us";
        session.default = "niri";
        appearance = {
          scheme = "Synced";
          hide_logo = true;
        };
      };
    };
  });

  perSystem = {
    pkgs,
    lib,
    self',
    ...
  }: {
    packages.niri = inputs.wrappers.wrappers.niri.wrap {
      inherit pkgs;

      settings = {
        spawn-at-startup = [
          (lib.getExe self'.packages.noctalia)
        ];

        xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

        input.keyboard = {
          xkb = {
            layout = "us,ru";
            options = "grp:shifts_toggle";
          };
        };

        layout.gaps = 5;

        binds = {
          "Mod+Space".spawn-sh = "${lib.getExe self'.packages.noctalia} ipc call launcher toggle";
          "Mod+Return".spawn-sh = lib.getExe self'.packages.kitty;
        };
      };
    };
  };
}
