{
  flake.modules.nixos.sddm-autologin = {
    config,
    ...
  }: {
    services.displayManager = {
      autoLogin.enable = true;
      autoLogin.user = "${config.preferences.mainUser.username}";
    };
  };
}
