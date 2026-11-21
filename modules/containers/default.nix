{self, ...}: {
  flake.modules.nixos.containers = let
    containers = with self.modules.nixos; [
      containerHomepage
      containerImmich
      containerKuma
      containerHomeassistant
    ];
  in
    {
      lib,
      config,
      ...
    }: {
      imports = containers;
    };
}
