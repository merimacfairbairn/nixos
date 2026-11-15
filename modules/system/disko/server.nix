{inputs, ...}: {
  flake.diskoConfigurations.server = {
    lib,
    config,
    ...
  }: let
    cfg = config.disko;
    opts = ["compress=zstd" "noatime"];
  in {
    imports = [inputs.disko.nixosModules.disko];

    options.disko = {
      diskDevice = lib.mkOption {
        type = lib.types.str;
        default = "/dev/sda";
        description = "Target disk, e.g. /dev/disk/by-id/...";
      };
      swapSize = lib.mkOption {
        type = lib.types.str;
        default = "8G";
      };
    };

    config = {
      disko.devices.disk.main = {
        type = "disk";
        device = cfg.diskDevice;
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "cryptroot";
                passwordFile = "/tmp/luks-pass"; # install-time only
                settings = {
                  allowDiscards = true;
                  crypttabExtraOpts = ["tpm2-device=auto"];
                };
                content = {
                  type = "btrfs";
                  extraArgs = ["-f"];
                  subvolumes = {
                    "@root" = {
                      mountpoint = "/";
                      mountOptions = opts;
                    };
                    "@nix" = {
                      mountpoint = "/nix";
                      mountOptions = opts;
                    };
                    "@log" = {
                      mountpoint = "/var/log";
                      mountOptions = opts;
                    };
                    # Containers: images, volumes. Kept out of root snapshots.
                    "@docker" = {
                      mountpoint = "/var/lib/docker";
                      mountOptions = opts;
                    };
                    # Bulk service data (Immich library, DBs, compose volumes)
                    "@data" = {
                      mountpoint = "/srv";
                      mountOptions = ["noatime"];
                    };
                    "@swap" = {
                      mountpoint = "/.swap";
                      mountOptions = ["noatime"];
                      swap.swapfile.size = cfg.swapSize;
                    };
                  };
                };
              };
            };
          };
        };
      };

      services.btrfs.autoScrub = {
        enable = true;
        interval = "monthly";
      };

      boot.zswap.enable = true;
    };
  };
}
