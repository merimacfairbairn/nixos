{
    flake.nixosModules.bootconfig = let
    modules = with self.nixosModules; [
      self.diskoConfigurations.btrfs-luks-swap
      secure-boot-with-tpm
    ]

    in {
      imports = modules;
    };
}
