{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.server01 = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.modules.nixos; [
      server
      server01Config

      diskoServer
      securebootTPM
    ];
  };

  flake.modules.nixos.server01Config = {
    lib,
    config,
    ...
  }: {
    networking = {
      hostName = "server01";
    };

    users.users.${config.preferences.mainUser.username} = {
      hashedPasswordFile = lib.mkForce null;
      initialPassword = "123";
    };

    services.logind = {
      settings.Login = {
        HandleLidSwitch = "ignore";
        HandleLidSwitchExternalPower = "ignore";
        HandleLidSwitchDocked = "ignore";
      };
    };

    imports = [
      ./_hardware-configuration.nix
    ];
  };
}
