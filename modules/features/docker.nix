{
  flake.modules.nixos.docker = {config, ...}: {
    virtualisation.docker = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };

    users.users.${config.preferences.mainUser.username}.extraGroups = ["docker"];
  };

  flake.modules.nixos.preservation = {
    config,
    lib,
    ...
  }: let
    isDockerEnabled = config.virtualisation.docker.enable;
  in {
    preservation.preserveAt."/persist".directories = lib.mkIf isDockerEnabled [
      "/var/lib/docker"
    ];
  };
}
