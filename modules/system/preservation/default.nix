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
      # rollback results in sudo lectures after each reboot
      Defaults lecture = never
    '';

    preservation = {
      enable = true;

      preserveAt."/persist" = {
        files = [
          {
            file = "/etc/machine-id";
            inInitrd = true;
            how = "symlink";
            configureParent = true;
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

    # when the file does not exist yet, it is initialized with the string "uninitialized"
    # to satisfy the firstboot condition
    boot.initrd.systemd.tmpfiles.settings.preservation."/sysroot/state/etc/machine-id".f = {
      argument = "uninitialized";
    };

    # let the service commit the transient ID to the persistent volume
    systemd.services.systemd-machine-id-commit = {
      unitConfig.ConditionPathIsMountPoint = [
        ""
        "/persist/etc/machine-id"
      ];
      serviceConfig.ExecStart = [
        ""
        "systemd-machine-id-setup --commit --root /persist"
      ];
    };
  });
}
