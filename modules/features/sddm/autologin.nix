{
  self,
  inputs,
  ...
}: {
  flake.modules.nixos.sddm-autologin = {
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
