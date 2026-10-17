{
  flake.nixosModules.user = {
    lib,
    config,
    ...
  }: let
    username = config.preferences.user.name;
    inherit (lib) mkOption types;
  in {
    options.preferences.user.name = mkOption {
      type = types.str;
      default = "aboba";
    };

    config = {
      users.users.${username} = {
        isNormalUser = true;
        initialPassword = "12345";
        extraGroups = [
          "wheel"
          "networkmanager"
        ];
      };
    };
  };
}
