{self, ...}: {
  flake.nixosModules.desktop = let
    modules = with self.nixosModules; [
      base
      hyprland
      tailscale
      sddm
    ];
  in {
    imports = modules;
  };
}
