{ self, inputs, ... }: {

  flake.nixosModules.hummingbirdConfig = { pkgs, lib, ... }: {
    imports = [
      self.nixosModules.hummingbirdHardware
      self.nixosModules.niri
    ];

    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    environment.systemPackages = with pkgs; [
      vim
      wget
      openssh
      git
    ];

    networking.hostName = "hummingbird";
    networking.networkmanager.enable = true;
    time.timeZone = "Europe/London";

    users.users.aboba = {
      isNormalUser = true;
      initialHashedPassword = "$y$j9T$Q4Wug7I/IGRfjrdzSuh4V1$GFeD17figWIkj1Yk2mO3PAgT5nSK/LguUpUKWYzLh.4";
      extraGroups = [
        "wheel"
        "networkmanager"
      ];
    };

    # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
    system.stateVersion = "26.05"; # Did you read the comment?
  };
}
