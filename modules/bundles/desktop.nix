{self, ...}: {
  flake.nixosModules.desktop = let
    modules = with self.nixosModules; [
      base
      niri
    ];
  in {
    imports = modules;
  };
}
