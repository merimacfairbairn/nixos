{ self, inputs, ... }: {

  flake.nixosModules.hummingbirdConfig = { pkgs, lib, ... }: {
  imports = [
      self.nixosModules.hummingbirdHardware
    ];

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    environment.systemPackages = with pkgs; [
      vim
      wget
      openssh
      git
    ];

    # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
    system.stateVersion = "26.05"; # Did you read the comment?
    };
}

