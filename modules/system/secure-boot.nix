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

      configurationLimit = 4;
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

  flake.modules.nixos.preservation = {
    lib,
    config,
    ...
  }: {
    preservation.preserveAt."/persist" = {
      files = lib.mkIf config.boot.lanzaboote.autoEnrollKeys.enable [
        "/var/lib/auto-cryptenroll"
        "/var/lib/systemd/pcrlock.json"
      ];
      directories = lib.mkIf config.boot.lanzaboote.enable [
        "/var/lib/sbctl"
        "/var/lib/pcrlock.d"
      ];
    };
  };
}
