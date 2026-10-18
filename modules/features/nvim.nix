{moduleWithSystem, ...}: {
  flake.nixosModules.nvim = moduleWithSystem ({self', ...}: {
    programs.neovim = {
      enable = true;
      package = self'.packages.nvim;
    };
  });

  perSystem = {inputs', ...}: {
    packages.nvim = inputs'.nvim.packages.default;
  };
}
