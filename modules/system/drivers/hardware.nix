{...}: {
  flake.nixosModules.hardware = {pkgs, ...}: {
    hardware = {
      bluetooth.enable = true;
    };
  };
}
