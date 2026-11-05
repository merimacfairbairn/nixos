{
  inputs,
  config,
  ...
}: {
  flake.modules.nixos.sops = let
    isEd25519 = k: k.type == "ed25519";
    getKeyPath = k: k.path;
    keys = builtins.filter isEd25519 config.services.openssh.hostKeys;
  in {
    imports = [
      inputs.sops-nix.nixosModules.sops
    ];

    sops = {
      age.sshKeyPaths = map getKeyPath keys;
    };
  };

  flake.modules.nixos.preservation = {
    preservation.preserveAt."/persistent".files = [
      { file = "/etc/ssh/ssh_host_rsa_key"; how = "symlink"; configureParent = true; }
      { file = "/etc/ssh/ssh_host_ed25519_key"; how = "symlink"; configureParent = true; }
    ];
  };
}
