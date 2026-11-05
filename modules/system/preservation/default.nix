{inputs, ...}: {
  flake.modules.nixos.preservation = {
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
        ];

        users.aboba = {
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
