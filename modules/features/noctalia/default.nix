{inputs, ...}: {
  perSystem = {pkgs, ...}: {
    packages.myNoctalia = inputs.wrappers.wrappers.noctalia-shell.wrap {
      inherit pkgs;

      settings = builtins.fromJSON (builtins.readFile ./noctalia.json);
    };
  };
}
