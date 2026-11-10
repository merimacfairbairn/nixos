{moduleWithSystem, ...}: {
  flake.modules.nixos.nvim = moduleWithSystem ({self', ...}: {
    programs.neovim = {
      enable = true;
      package = self'.packages.nvim;
    };
  });

  perSystem = {inputs', ...}: {
    packages.nvim = inputs'.nvim.packages.default;
  };

  flake.modules.nixos.preservation = {
    config,
    lib,
    ...
  }: {
    preservation.preserveAt."/persist" = {
      users.${config.preferences.mainUser.username} = {
        directories = lib.mkIf config.programs.neovim.enable [
          ".local/share/nvim-merimac-remote"
        ];
      };
    };
  };
}
