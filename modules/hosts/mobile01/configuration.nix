{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.mobile01 = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      mobile01Config
      desktop
      development
      upower
      preservation

      self.diskoConfigurations.tmpfsRoot
      securebootTPM
    ];
  };

  flake.nixosModules.mobile01Config = {...}: {
    networking = {
      hostName = "mobile01";
    };

    imports = [
      ./_hardware-configuration.nix
    ];
  };
}
