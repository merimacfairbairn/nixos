{
  flake.modules.nixos.server = let
    modules = with self.modules.nixos; [
      base
      docker
      tailscale
    ];
  in {
    imports = modules;
  };
}
