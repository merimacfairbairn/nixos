{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.modules.nixos.preservation = moduleWithSystem ({flakeLocation, ...}: {config, lib, ...}: {
    imports = [inputs.preservation.nixosModules.default];

    boot.tmp.cleanOnBoot = true;

    boot.loader = {
      grub.enable = false;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    preservation = {
      enable = true;

      preserveAt."/persist" = {
        files = [
          {
            file = "/etc/machine-id";
            inInitrd = true;
          }
        ];

        directories = [
          "/var/lib/systemd/timers/"
          "/var/lib/nixos"
          "/var/log"
          "/var/lib/bluetooth"
          "/etc/NetworkManager/system-connections"
          {
            directory = "/tmp";
            mode = "1777";
          }
        ] ++ lib.optional (flakeLocation != "") {
            directory = flakeLocation;
            user = config.preferences.mainUser.username;
            group = "users";
        };

        users.${config.preferences.mainUser.username} = {
          files = [ ".zsh_history" ];
          directories = [
            ".local/state/wireplumber"
            ".ssh"
            "Documents"
            "Projects"
            "Media"
          ];
        };
      };
    };
  });
}
