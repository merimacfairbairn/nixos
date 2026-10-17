{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.base = {pkgs, ...}: let
    selfpkgs = self.packages.${pkgs.stdenv.hostPlatform.system};
  in {
    environment.systemPackages = [
      selfpkgs.git
    ];
  };

  perSystem = {pkgs, ...}: {
    packages.myGit = inputs.wrapper-modules.wrappers.git.wrap {
      inherit pkgs;
      package = pkgs.git;

      settings = {
        user = {
          name = "Merimac";
          email = "merimacfairbairn.git@gmail.com";
        };

        init.defaultBranch = "main";

        pull.rebase = true;
        rerere.enable = true;
      };
    };
  };
}
