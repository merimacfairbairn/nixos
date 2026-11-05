{self, ...}: {
  flake.modules.nixos.systemTheme = {...}: let
    modules = with self.modules.nixos; [
      bibataCursors
      catppuccinGtk
    ];
  in {
    imports = modules;
  };
}
