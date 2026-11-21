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

  flake.modules.nixos.preservation = {
    config,
    lib,
    ...
  }: {
    preservation.preserveAt."/persist".users.${config.preferences.mainUser.username}.directories = lib.mkIf config.programs.steam.enable [
      ".local/share/Steam" # library, compatdata (Proton prefixes and saves), shadercache
      ".steam" # registry.vdf, pid, runtime symlinks
      ".cache/nvidia" # NVIDIA GL/Vulkan shader cache
      ".cache/protontricks"
    ];
  };
}
