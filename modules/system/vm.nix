{
  flake.modules.nixos.vm = {lib, ...}: {
    virtualisation.vmVariant = {
      # mkVMOverride (priority 10) beats mkForce (50), so it wins even if a host forces a value

      # --- things that assert on real hardware ---
      services.btrfs.autoScrub.enable = lib.mkVMOverride false;
      boot.zswap.enable = lib.mkVMOverride false;
      swapDevices = lib.mkVMOverride [];
      zramSwap.enable = lib.mkVMOverride false;
      services.fstrim.enable = lib.mkVMOverride false;
      services.smartd.enable = lib.mkVMOverride false;
      services.tlp.enable = lib.mkVMOverride false;
      services.thermald.enable = lib.mkVMOverride false;
      boot.initrd.luks.devices = lib.mkVMOverride {};

      # --- always be able to get in ---
      services.openssh = {
        enable = true;
        settings = {
          PermitRootLogin = lib.mkVMOverride "yes";
          PasswordAuthentication = lib.mkVMOverride true;
        };
      };
      users.users.root.initialPassword = lib.mkVMOverride "test";
      users.mutableUsers = lib.mkVMOverride true;

      # --- VM sizing and access ---
      virtualisation = {
        memorySize = 4096;
        cores = 2;
        diskSize = 20 * 1024;
        graphics = lib.mkDefault false; # headless by default; override for desktop hosts
        forwardPorts = [
          {
            from = "host";
            host.port = 2222;
            guest.port = 22;
          }
        ];
      };
    };
  };
}
