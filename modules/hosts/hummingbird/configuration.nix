{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.hummingbird = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.hummingbirdConfig
    ];
  };

  flake.nixosModules.hummingbirdConfig = {pkgs, ...}: {
    imports = with self.nixosModules; [
      hummingbirdHardware
      base
      niri
    ];

    environment.systemPackages = with pkgs; [
      vim
      wget
      openssh
    ];

    networking.hostName = "hummingbird";
    networking.networkmanager.enable = true;
    time.timeZone = "Europe/London";

    # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
    system.stateVersion = "26.05"; # Did you read the comment?
  };
}
