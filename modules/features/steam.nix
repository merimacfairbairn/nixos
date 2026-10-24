{moduleWithSystem, ...}: {
  flake.nixosModules.steam = moduleWithSystem ({
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
