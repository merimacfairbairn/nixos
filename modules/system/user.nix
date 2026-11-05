{self, ...}: {
  flake.modules.nixos.user = {
    pkgs,
    lib,
    config,
    ...
  }: let
    inherit (lib) mkOption types;
    username = config.preferences.mainUser.username;

    modules = with self.modules.nixos; [
      zsh
    ];
  in {
    imports = modules;

    options.preferences.mainUser.username = mkOption {
      type = types.str;
      default = "user01";
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
