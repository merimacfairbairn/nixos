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
        extra-config = ''
          [image]
          format = "kitty"
          path = "${./cat.png}"
          position = "left"
          width = 15
          padding = [0, 0, 0, 0]
        '';

        final-config = pkgs.writeText "config.toml" ''
          ${extra-config}

          ${builtins.readFile ./config.toml}
        '';
      in
        inputs.wrappers.lib.wrapPackage ({...}: {
          inherit pkgs;
          package = inputs'.otter-launcher.packages.default;
          runtimePkgs = with pkgs; [
            fsel
            bluetui
          ];
          flags = {
            "-c" = final-config;
          };
        });
    };
  };
}
