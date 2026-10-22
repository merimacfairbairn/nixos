{self, ...}: {
  flake.nixosModules.desktop = let
    modules = with self.nixosModules; [
      base
      hyprland
    ];
  in {
    imports = modules;
  };
}
