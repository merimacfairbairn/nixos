{
  self,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.base = moduleWithSystem ({...}: let
    modules = with self.nixosModules; [
      nix
      git
      kitty
      user
    ];
  in {
    imports = modules;
  });
}
