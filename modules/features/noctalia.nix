{ self, inputs, ... }: {
  perSystem = { pkgs, ... }: {
    packages.myNoctalia = inputs.wrapper-module.wrappers.noctalia-shell.wrap {
      settings = {
        (builtins.fromJSON
            (builtins.readFile ./noctalia.json)).settings;
      };
    };
  };
}
