{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.modules.nixos.sops = moduleWithSystem({pkgs, ...}: {
    imports = [inputs.sops-nix.nixosModules.sops];

    sops = {
      defaultSopsFile = ./secrets.yaml;
      secrets.user-password.neededForUsers = true;
    };

    services.openssh.hostKeys = [
      {
        path = "/persist/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];

    environment.systemPackages = with pkgs; [
      sops
      age
      ssh-to-age
    ];
  });
}
