{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.hummingbird = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      hummingbirdConfig
      hummingbirdHardware
      desktop
      development
      upower
    ];
  };

  flake.nixosModules.hummingbirdConfig = {...}: {
    networking = {
      hostName = "hummingbird";
    };
  };
}
