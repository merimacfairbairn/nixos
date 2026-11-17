{self, ...}: {
  flake.modules.nixos.containers = let
    containers = with self.modules.nixos; [
      docker

      containerCaddy
      containerHomepage
      containerImmich
      containerKuma
    ];
  in {
    imports = containers;
  };
}
