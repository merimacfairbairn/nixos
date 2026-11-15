{self, ...}: {
  flake.modules.nixos.base = {
    config,
    pkgs,
    ...
  }: let
    modules = with self.modules.nixos; [
      nix
      user
      locale
      networking
      hardware
      sops
    ];
  in {
    imports = modules;

    services = {
      openssh = {
        enable = true;
        openFirewall = true;
        settings = {
          PermitRootLogin = "no";
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          AllowUsers = [config.preferences.mainUser.username];
          MaxAuthTries = 3;
        };
      };
    };

    programs.ssh = {
      startAgent = true;
      agentTimeout = "1h";
    };

    environment.systemPackages = with pkgs; [
      vim
      unzip
      p7zip-rar
      usbutils
      lsof
      gvfs
      libnotify
      python315
      curlWithGnuTls
      wget
    ];

    system.stateVersion = "26.05";
  };
}
