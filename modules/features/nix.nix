{
  self,
  inputs,
  ...
}: {
  perSystem = {pkgs, ...}: {
    packages.nh = inputs.wrapper-modules.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.nh;
      env.NH_FLAKE = "$HOME/nixconf";
    };
  };

  flake.nixosModules.base = {pkgs, ...}: let
    selfpkgs = self.packages.${pkgs.system};
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
}
