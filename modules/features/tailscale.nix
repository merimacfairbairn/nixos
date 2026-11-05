{
  self,
  moduleWithSystem,
  ...
}: {
  flake.modules.nixos.tailscale = moduleWithSystem ({...}: {
    services.tailscale = {
      enable = true;
    };
  });
}
