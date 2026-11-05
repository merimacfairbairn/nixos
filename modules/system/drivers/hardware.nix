{...}: {
  flake.modules.nixos.hardware = {pkgs, ...}: {
    hardware = {
      bluetooth.enable = true;
    };
  };
}
