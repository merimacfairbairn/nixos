{moduleWithSystem, ...}: {
  flake.nixosModules.nvidiaDrivers = moduleWithSystem ({pkgs, ...}: {
    hardware.graphics = {
      enable = true;
      enable32bit = true;
    };

    services.xserver.videoDrivers = ["nvidia"];

    hardware.nvidia = {
      modesetting.enable = true;
      open = true;
      nvidiaSettings = true;
      package = pkgs.linuxPackages_latest.nvidiaPackages.latest;
    };
  });
}
