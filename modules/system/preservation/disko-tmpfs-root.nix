{inputs, ...}: {
  flake.diskoConfigurations.tmpfsRoot = {
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
        default = "/dev/sda"
      };
      swapSize = lib.mkOption {
        type = lib.types.str;
        default = "16G";
      };
    };

    config = {
      fileSystems."/var/log".neededForBoot = true;
      fileSystems."/nix".neededForBoot = true;

      disko.devices.nodev = {
        "/" = {
          fsType = "tmpfs";
          mountOptions = [
            "size=25%"
            "mode=755"
          ];
        };
      };

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
                    "@nix" = {
                      mountpoint = "/nix";
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                    "@persist" = {
                      mountpoint = "/persist";
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

      boot.zswap = {
        enable = true;
        compressor = "zstd";
        maxPoolPercent = 20;
        shrinkerEnabled = true;
      };
    };
  };
}
