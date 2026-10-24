{
  self,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.tailscale = moduleWithSystem ({...}: {
    services.tailscale = {
      enable = true;
    };
  });
}
