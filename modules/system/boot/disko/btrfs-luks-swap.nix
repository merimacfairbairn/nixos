{inputs, ...}: {
  flake.diskoConfigurations.btrfs-luks-swap = {
    lib,
    config,
    ...
  }: let
    cfg = config.disko;
  in {
    imports = [inputs.disko.nixosModules.disko];

    options.disko = {
      diskDevice = lib.mkOption {
        type = lib.types.str;
        description = "Target disk, e.g. /dev/disk/by-id/nvme-...";
      };
      swapSize = lib.mkOption {
        type = lib.types.str;
        default = "16G";
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
                    "@" = {
                      mountpoint = "/";
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                    "@home" = {
                      mountpoint = "/home";
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                    "@nix" = {
                      mountpoint = "/nix";
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                    "@log" = {
                      mountpoint = "/var/log";
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                    "@snapshots" = {
                      mountpoint = "/.snapshots";
                      mountOptions = ["compress=zstd" "noatime"];
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

      fileSystems."/var/log".neededForBoot = true;

      boot.zswap = {
        enable = true;
        compressor = "zstd";
        maxPoolPercent = 20;
        shrinkerEnabled = true;
      };
    };
  };
}
