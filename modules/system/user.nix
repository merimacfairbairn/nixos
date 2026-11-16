{self, ...}: {
  flake.modules.nixos.user = {
    pkgs,
    lib,
    config,
    ...
  }: let
    inherit (lib) mkOption types;
    username = config.preferences.mainUser.username;
    sshKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICwDtrUKf6KE6F3VyqZU9FXY7NLR2yo4+uJnhawIDRQN merimacfairbairn.git@gmail.com"
    ];

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
        hashedPasswordFile = lib.mkDefault config.sops.secrets.user-password.path;
        shell = pkgs.zsh;
        extraGroups = [
          "wheel"
          "networkmanager"
        ];

        openssh.authorizedKeys.keys = sshKeys;
      };
    };
  };
}
