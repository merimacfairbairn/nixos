{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.hummingbird = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      hummingbirdConfig
      hummingbirdHardware
      base
      niri
      development
      kitty
    ];
  };

  flake.nixosModules.hummingbirdConfig = {...}: {
    networking = {
      hostName = "hummingbird";
    };
  };
}
