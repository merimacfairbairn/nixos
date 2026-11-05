{self, ...}: {
  flake.modules.nixos.user = {
    pkgs,
    lib,
    config,
    ...
  }: let
    inherit (lib) mkOption types;
    username = config.preferences.user.name;

    modules = with self.modules.nixos; [
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
