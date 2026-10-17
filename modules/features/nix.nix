{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.base = {pkgs, ...}: let
    selfpkgs = self.packages.${pkgs.stdenv.hostPlatform.system};
  in {
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Nix tooling
    environment.systemPackages = with pkgs; [
      nixd
      alejandra
      selfpkgs.nh
    ];
  };

  perSystem = {pkgs, ...}: {
    packages.nh = inputs.wrapper-modules.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.nh;
      env.NH_FLAKE = "$HOME/nixconf";
    };
  };
}
