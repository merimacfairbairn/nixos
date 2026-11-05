{
  self,
  moduleWithSystem,
  ...
}: {
  flake.modules.nixos.development = moduleWithSystem ({pkgs, ...}: let
    modules = with self.modules.nixos; [
      zsh
      nvim
      git
    ];
  in {
    imports = modules;
    environment.systemPackages = with pkgs; [
      devenv
    ];
  });
}
