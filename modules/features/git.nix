{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.git = moduleWithSystem ({self', ...}: {...}: {
    environment.systemPackages = [
      self'.packages.git
    ];
  });

  perSystem = {pkgs, ...}: {
    packages.git = inputs.wrappers.wrappers.git.wrap {
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
