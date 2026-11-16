{self, ...}: {
  flake.modules.nixos.server = let
    modules = with self.modules.nixos; [
      base
      docker
      tailscale
      containers
    ];
  in {
    imports = modules;
  };
}
