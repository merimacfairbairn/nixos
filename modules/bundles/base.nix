{
  self,
  moduleWithSystem,
  ...
}: {
  flake.nixModules.base = moduleWithSystem ({...}: let
    modules = with self.nixosModules; [
      nix
      git
      user
    ];
  in {
    imports = modules;
  });
}
