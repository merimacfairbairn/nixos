{self, ...}: {
  flake.modules.nixos.server = let
    modules = with self.modules.nixos; [
      base
      tailscale
      containers
    ];
  in {
    imports = modules;

    services.tailscale.extraUpFlags = ["--advertise-tags=tag:server"]
  };
}
