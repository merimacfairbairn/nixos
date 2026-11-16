{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.modules.nixos.sops = moduleWithSystem ({pkgs, ...}: {
    config,
    lib,
    ...
  }: {
    imports = [inputs.sops-nix.nixosModules.sops];

    sops = {
      defaultSopsFile = ./secrets.yaml;
      secrets.user-password.neededForUsers = true;
      age.sshKeyPaths =
        lib.mkIf (config.preservation.enable or false)
        ["/persist/etc/ssh/ssh_host_ed25519_key"];
    };

    environment.systemPackages = with pkgs; [
      sops
      age
      ssh-to-age
    ];
  });
}
