{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.base = moduleWithSystem ({self', ...}: {pkgs, ...}: {
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Nix tooling
    environment.systemPackages = with pkgs; [
      nixd
      alejandra
      self'.packages.nh
    ];
  });

  perSystem = {pkgs, ...}: {
    packages.nh = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;

      package = pkgs.nh;
      env = {
        "NH_FLAKE" = "$HOME/nixconf";
      };
    };
  };
}
