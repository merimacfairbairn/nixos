{inputs, ...}: {
  flake.modules.nixos.securebootTPM = {
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

      autoGenerateKeys.enable = true;
      autoEnrollKeys = {
        enable = true;
        includeMicrosoftKeys = true;
      };
    };
  };

  flake.modules.nixos.preservation = {
    preservation.preserveAt."/persist" = {
      files = [
        "/var/lib/auto-cryptenroll"
      ];
      directories = [
        "/var/lib/sbctl"
      ];
    };
  };
}
