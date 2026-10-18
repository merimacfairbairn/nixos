{self, ...}: {
  flake.nixosModules.user = {
    pkgs,
    lib,
    config,
    ...
  }: let
    inherit (lib) mkOption types;
    username = config.preferences.user.name;

    modules = with self.nixosModules; [
      zsh
    ];
  in {
    imports = modules;

    options.preferences.user.name = mkOption {
      type = types.str;
      default = "aboba";
    };

    config = {
      users.users.${username} = {
        description = "${username}";
        isNormalUser = true;
        initialPassword = "12345";
        shell = pkgs.zsh;
        extraGroups = [
          "wheel"
          "networkmanager"
        ];
      };
    };
  };
}
