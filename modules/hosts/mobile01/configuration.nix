{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.mobile01 = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      mobile01Config
      mobile01Hardware
      desktop
      development
      upower
    ];
  };

  flake.nixosModules.mobile01Config = {...}: {
    networking = {
      hostName = "mobile01";
    };
  };
}
