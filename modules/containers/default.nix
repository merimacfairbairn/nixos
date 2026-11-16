{self, ...}: {
  flake.modules.nixos.containers = let
    containers = with self.modules.nixos; [
      containerImmich
      containerKuma
    ];
  in {
    imports = containers;
  };
}
