{self, ...}: {
  flake.modules.nixos.containers = let
    containers = with self.modules.nixos; [
      containerImmich
    ];
  in {
    imports = containers;
  };
}
