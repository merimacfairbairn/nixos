{self, moduleWithSystem, ...}: {

  flake.nixosModules.development = moduleWithSystem({pkgs, ...}: let
    modules = with self.nixosModules; [
      zsh
      nvim
      git
    ];
  in
    {
      imports = modules;
      environment.systemPackages = with pkgs; [
        devenv
      ];
    });
}
