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

      autoGenerateKeys.enable = true;
      autoEnrollKeys = {
        enable = true;
        includeMicrosoftKeys = true;
      };
    };

    # Enable measured boot
    # boot.lanzaboote = {
    #   configurationLimit = 4;  # Limit generations to 4 to prement error
    #   measuredBoot = {
    #     enable = true;
    #     pcrs = [
    #       0
    #       4
    #       7
    #     ];
    #   };
    # };
  };
}
