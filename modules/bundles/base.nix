{
  self,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.base = moduleWithSystem ({...}: let
    modules = with self.nixosModules; [
      nix
      user
      locale
      networking
    ];
  in {
    imports = modules;
  });
}
