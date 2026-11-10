{self, ...}: {
  flake.modules.nixos.desktop = let
    modules = with self.modules.nixos; [
      base
      hyprland
      tailscale
      sddm
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
