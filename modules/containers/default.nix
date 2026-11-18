{self, ...}: {
  flake.modules.nixos.containers = let
    containers = with self.modules.nixos; [
      containerHomepage
      containerImmich
      containerKuma
      containerHomeassistant
    ];

    # name = port mappings
    services = {
      homepage = 13000;
      immich = 12283;
      kuma = 13001;
    };
  in
    {
      lib,
      config,
      ...
    }: {
      imports = containers;
    };
}
