{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.nix = moduleWithSystem ({self', ...}: {pkgs, ...}: {
    nix.settings = {
      cores = 6;
      download-buffer-size = 524288000;
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      nixPath = ["nixpkgs=${inputs.nixpkgs}"];
      optimise.automatic = true;
      gc = {
        automatic = true;
        dates = "daily";
        options = "--delete-older-than 5d";
      };
    };

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
