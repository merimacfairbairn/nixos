{
  moduleWithSystem,
  self,
  ...
}: {
  flake.nixosModules.hyprland = moduleWithSystem ({
    self',
    pkgs,
    ...
  }: {...}: let
    modules = with self.nixosModules; [
      audio
      systemTheme
      quickshell
    ];

    lib = pkgs.lib;
  in {
    imports = modules;

    options = {
      tabletSupport = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable tablet support across all modules";
      };
    };

    config = {
      programs.hyprland = {
        enable = true;
        package = self'.packages.hyprland;
      };

      services.displayManager.defaultSession = "hyprland";
      services.xserver.enable = true;
      services.seatd.enable = true;
      security.polkit.enable = true;

      environment.systemPackages = with pkgs; [
        gsettings-desktop-schemas
        glib
      ];
    };
  });
  perSystem = {
    self',
    inputs',
    ...
  }: {
    packages = {
      hyprland = inputs'.hyprland.packages.default.wrap {
        wrapperImplementation = "binary";

        runtimePkgs = with self'.packages; [
          {
            data = kitty;
            prefix = true;
          }
          {
            data = quickshell;
            prefix = true;
          }
          {
            data = wpaperd;
            prefix = true;
          }
          {
            data = otter-launcher;
            prefix = true;
          }
          # hyprlock = self'.packages.hyprlock;
        ];
      };
    };
  };
}
