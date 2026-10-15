{ self, inputs, ...}: {
    flake.nixosConfigurations.hummingbird = inputs.nixpkgs.lib.nixosSystem {
        modules = [
           self.nixosModules.hummingbirdConfig
        ];
    };
}
