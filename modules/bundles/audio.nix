{...}: {
  flake.nixosModules.audio = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      playerctl
      pavucontrol
    ];

    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;

      alsa.enable = true;
      alsa.support32Bit = true;

      pulse.enable = true;
      jack.enable = true;

      wireplumber.enable = true;
    };
  };
}
