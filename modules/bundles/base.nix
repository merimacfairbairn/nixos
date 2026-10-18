{self, ...}: {
  flake.nixosModules.base = {pkgs, ...}: let
    modules = with self.nixosModules; [
      nix
      user
      locale
      networking
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
