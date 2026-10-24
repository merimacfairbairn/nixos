{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.sddm-autologin = {
    pkgs,
    lib,
    ...
  }: {
    services.displayManager = {
      autoLogin.enable = true;
      autoLogin.user = "aboba";
    };
  };
}
