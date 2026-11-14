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
          [[image]]
          format = "symbol" # graphics protocols to use; options: kitty, sixel, iterm2, symbol
          path = "${./cat.png}" # path to the image file
          position = "left" # image placement; options: left, right, top, bottom
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
