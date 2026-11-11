{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.modules.nixos.preservation = moduleWithSystem ({flakeLocation, ...}: {
    config,
    lib,
    ...
  }: {
    imports = [inputs.preservation.nixosModules.default];

    boot.tmp.cleanOnBoot = true;

    boot.loader = {
      grub.enable = false;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    security.sudo.extraConfig = ''
      # Disable lecturing
      Defaults lecture = never
    '';

    preservation = {
      enable = true;

      preserveAt."/persist" = {
        files = [
          {
            file = "/etc/machine-id";
            inInitrd = true;
          }
          {
            file = "/etc/ssh/ssh_host_ed25519_key";
            how = "symlink";
            configureParent = true;
          }
          {
            file = "/etc/ssh/ssh_host_rsa_key";
            how = "symlink";
            configureParent = true;
          }
        ];

        directories =
          [
            "/var/lib/systemd/timers/"
            "/var/lib/nixos"
            "/var/log"
            "/var/lib/bluetooth"
            "/etc/NetworkManager/system-connections"
            {
              directory = "/tmp";
              mode = "1777";
            }
          ]
          ++ lib.optional (flakeLocation != "") {
            directory = flakeLocation;
            user = config.preferences.mainUser.username;
            group = "users";
          };

        users.${config.preferences.mainUser.username} = {
          files = [".zsh_history"];
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

    # systemd-machine-id-commit.service would fail, but it is not relevant
    # in this specific setup for a persistent machine-id so we disable it
    #
    # see the firstboot example below for an alternative approach
    systemd.suppressedSystemUnits = ["systemd-machine-id-commit.service"];
  });
}
