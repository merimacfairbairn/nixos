{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.station01 = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.modules.nixos; [
      station01Config
      desktop
      development
      steam

      preservation
      diskoTmpfsRoot
      securebootTPM
    ];
  };

  flake.modules.nixos.station01Config = {pkgs, ...}: {
    networking = {
      hostName = "station01";
    };

    boot.kernelPackages = pkgs.linuxKernel_zen;

    disko.diskDevice = "/dev/disk/by-id/nvme-WD_Blue_SN570_1TB_22404S801452";

    imports = [
      ./_hardware-configuration.nix
    ];
  };
}
