{moduleWithSystem, ...}: {
  flake.nixosModules.libvirt = moduleWithSystem ({...}: {
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        runAsRoot = true;
      };
    };
    programs.virt-manager.enable = true;
  });
}
