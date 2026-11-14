{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.modules.nixos.otter-launcher = moduleWithSystem ({self', ...}: {
    environment.systemPackages = [
      self'.packages.otter-launcher
    ];
  });
  perSystem = {
    pkgs,
    inputs',
    ...
  }: {
    packages = {
      otter-launcher = let
        final-config = pkgs.writeText "config.toml" ''
          ${builtins.readFile ./config.toml}
        '';
      in
        inputs.wrappers.lib.wrapPackage ({...}: {
          inherit pkgs;
          package = inputs'.otter-launcher.packages.default;
          runtimePkgs = with pkgs; [
            fsel
            bluetui
            nmtui
          ];
          flags = {
            "-c" = final-config;
          };
        });
    };
  };
}
