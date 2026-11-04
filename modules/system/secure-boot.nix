{inputs, ...}: {
  flake.nixosModules.securebootTPM = {
    lib,
    pkgs,
    ...
  }: {
    imports = [inputs.lanzaboote.nixosModules.lanzaboote];

    environment.systemPackages = [pkgs.sbctl];

    boot.loader.systemd-boot.enable = lib.mkForce false;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
      # Recent lanzaboote only; check the README for your pinned release.
      autoGenerateKeys.enable = true;
      autoEnrollKeys = {
        enable = true;
        includeMicrosoftKeys = true;
      };
    };

    # Enable measured boot
    boot.initrd.systemd.enable = true;
    boot.lanzaboote = {
      measuredBoot = {
        enable = true;
        pcrs = [
          0
          4
          7
        ];
      };
    };

  };
}
