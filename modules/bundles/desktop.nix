{self, ...}: {
  flake.modules.nixos.desktop = let
    modules = with self.modules.nixos; [
      base
      hyprland
      tailscale
      sddm
      preservation
    ];
  in
    {
      pkgs,
      config,
      ...
    }: {
      imports = modules;

      environment.systemPackages = with pkgs; [
        keepassxc
      ];

      virtualisation.vmVariant.virtualisation.graphics = true;

      preservation.preserveAt."/persist" = {
        directories = [
          "/var/lib/sddm"
          "/var/lib/tailscale"
        ];
        users.${config.preferences.mainUser.username} = {
          directories = [
            ".config/mozilla"
            ".config/syncthing"
            ".config/keepassxc"
            ".local/state/keepassxc"
          ];
        };
      };
    };
}
