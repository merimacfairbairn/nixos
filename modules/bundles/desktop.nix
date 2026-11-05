{self, ...}: {
  flake.modules.nixos.desktop = let
    modules = with self.modules.nixos; [
      base
      hyprland
      tailscale
      sddm
    ];
  in {
    imports = modules;
  };
}
