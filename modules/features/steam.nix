{moduleWithSystem, ...}: {
  flake.modules.nixos.steam = moduleWithSystem ({
    pkgs,
    inputs',
    lib,
    ...
  }: {
    programs.steam = {
      enable = true;
      protontricks.enable = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };
  });
}
