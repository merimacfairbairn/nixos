{
  flake.modules.nixos.containerHomeassistant = {
    config,
    pkgs,
    ...
  }: let
    name = "home-assistant";
    dir = "/var/lib/homeassistant";

    # Seeded once; HA owns the file afterwards (tmpfiles "C" never overwrites)
    # Without trusted proxies HA returns 400 behind tailscale serve
    seedConfig = pkgs.writeText "configuration.yaml" ''
      default_config:

      http:
        use_x_forwarded_for: true
        trusted_proxies:
          - 127.0.0.1
          - ::1
    '';
  in {
    systemd.tmpfiles.rules = [
      "d ${dir} 0755 root root -"
      "C ${dir}/configuration.yaml 0644 root root - ${seedConfig}"
    ];

    virtualisation.oci-containers.containers.homeassistant = {
      image = "ghcr.io/home-assistant/home-assistant:stable";
      volumes = [
        "${dir}:/config"
        "/etc/localtime:/etc/localtime:ro"
      ];
      # Host networking is needed so HA can broadcast-discover the plugs on your LAN.
      # HA then listens directly on :8123 (no `ports` mapping).
      extraOptions = ["--network=host"];
    };

    systemd.services."tailscale-serve-${name}" = {
      description = "Tailscale service ${name}";
      after = ["tailscaled.service"];
      wants = ["tailscaled.service"];
      wantedBy = ["multi-user.target"];
      path = [config.services.tailscale.package];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = 5;
      };
      script = ''
        until tailscale status --peers=false >/dev/null 2>&1; do sleep 2; done
        tailscale serve --service=svc:${name} --https=443 http://localhost:8123
      '';
    };
  };
}
