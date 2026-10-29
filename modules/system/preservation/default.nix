{config, ...}: {
  flake.nixosModules.preservation = {
    boot.tmp.cleanOnBoot = true;
    preservation = {
      enable = true;

      preserveAt."/persistent" = {
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
          "/tmp"
        ];

        users.${config.preferences.user.name} = {
          files = [];
          directories = [
            ".local/state/wireplumber"
            "Documents"
            "Projects"
            "Media"
          ];
        };
      };
    };
  };
}
