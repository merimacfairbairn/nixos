{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.nix = moduleWithSystem ({self', ...}: {pkgs, ...}: {
    nix = {
      settings = {
        cores = 6;
        trusted-users = ["root" "aboba"];
        download-buffer-size = 524288000;
        experimental-features = [
          "nix-command"
          "flakes"
        ];
      };

      gc = {
        automatic = true;
        dates = "daily";
        options = "--delete-older-than 5d";
      };

      optimise.automatic = true;

      nixPath = ["nixpkgs=${inputs.nixpkgs}"];
    };

    nixpkgs.config.allowUnfree = true;

    # Nix tooling
    environment.systemPackages = with pkgs; [
      nixd
      alejandra
      self'.packages.nh
    ];
  });

  perSystem = {pkgs, ...}: {
    _module.args = {
      flakeLocation = builtins.getEnv "PWD";
    };

    packages.nh = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;

      package = pkgs.nh;
      env = {
        "NH_FLAKE" = "$HOME/nixconf";
      };
    };
  };
}
