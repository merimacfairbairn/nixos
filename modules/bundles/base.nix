{self, ...}: {
  flake.modules.nixos.base = {pkgs, ...}: let
    modules = with self.modules.nixos; [
      nix
      user
      locale
      networking
      hardware
      preservation
      sops
    ];
  in {
    imports = modules;

    services = {
      openssh = {
        enable = true;
        settings = {
          PermitRootLogin = "yes";
        };
      };
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
