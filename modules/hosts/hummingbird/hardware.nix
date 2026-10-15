{ self, inputs, ... }: {

    flake.nixosModules.hummingbirdHardware = { config, lib, pkgs, modulesPath, ... }: {

        imports = [
            (modulesPath + "/installer/scan/not-detected.nix")
        ];

        boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" "sdhci_pci" ];
        boot.initrd.kernelModules = [ ];
        boot.kernelModules = [ ];
        boot.extraModulePackages = [ ];

        boot.loader.systemd-boot.enable = true;
        boot.loader.systemd-boot.graceful = true;
        boot.loader.efi.canTouchEfiVariables = true;
        boot.kernelPackages = pkgs.linuxPackages_latest;

        fileSystems."/" =
        { device = "/dev/mapper/lukscontainer";
            fsType = "btrfs";
            options = [ "noatime" "compress=zstd" "subvol=@root" ];
        };

        boot.initrd.luks.devices."lukscontainer".device = "/dev/disk/by-uuid/2a3e293a-3d3d-45c6-aa7b-dec7ffefb175";

        fileSystems."/home" =
        { device = "/dev/mapper/lukscontainer";
            fsType = "btrfs";
            options = [ "noatime" "compress=zstd" "subvol=@home" ];
        };

        fileSystems."/nix" =
        { device = "/dev/mapper/lukscontainer";
            fsType = "btrfs";
            options = [ "noatime" "compress=zstd" "subvol=@nix" ];
        };

        fileSystems."/var/log" =
        { device = "/dev/mapper/lukscontainer";
            fsType = "btrfs";
            options = [ "noatime" "compress=zstd" "subvol=@log" ];
        };

        fileSystems."/.snapshots" =
        { device = "/dev/mapper/lukscontainer";
            fsType = "btrfs";
            options = [ "noatime" "compress=zstd" "subvol=@snapshots" ];
        };

        fileSystems."/boot" =
        { device = "/dev/disk/by-uuid/2179-7057";
            fsType = "vfat";
            options = [ "fmask=0022" "dmask=0022" ];
        };

        swapDevices = [ ];

        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
        hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };

}
