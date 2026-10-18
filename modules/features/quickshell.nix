{
  moduleWithSystem,
  inputs,
  ...
}: {
  flake.nixosModules.quickshell = moduleWithSystem ({
    self',
    pkgs,
    ...
  }: {config, ...}: {
    environment.systemPackages = with self'.packages;
      [
        quickshell
      ]
      ++ (
        if config.tabletSupport == true
        then
          # If on tablet enable on screen keyboard
          (with pkgs; [
            wvkbd
          ])
        else []
      );
  });
  perSystem = {pkgs, ...}: {
    packages.quickshell = inputs.wrappers.wrappers.quickshell.wrap {
      inherit pkgs;
      configDir = inputs.quickshell;
      configFile = "${inputs.quickshell}/shell.qml";
    };
  };
}
