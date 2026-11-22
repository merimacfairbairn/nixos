{self, ...}: {
  flake.modules.nixos.containerHomeassistant = {
    config,
    pkgs,
    ...
  }: let
    name = "home-assistant";
    dir = "/var/lib/homeassistant";

    integrations = with self.modules.nixos; [integrationMatterServer];
  in {
    imports = integrations;

    systemd.tmpfiles.rules = [
      "d ${dir} 0755 root root -"
    ];

    virtualisation.oci-containers.containers.homeassistant = {
      image = "ghcr.io/home-assistant/home-assistant:stable";
      volumes = [
        "${dir}:/config"
        "/etc/localtime:/etc/localtime:ro"
        "/run/dbus:/run/dbus:ro"
      ];
      # Host networking is needed so HA can broadcast-discover the plugs on your LAN.
      # HA then listens directly on :8123 (no `ports` mapping).
      extraOptions = [
        "--network=host"
        "--cap-add=NET_ADMIN"
        "--cap-add=NET_RAW"
      ];
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

    networking.firewall.interfaces."wlp3s0" = {
      allowedTCPPorts = [8123]; # HA, so the Companion app can reach it on LAN
      allowedUDPPorts = [5353]; # mDNS replies, needed to discover the plug
    };
  };
}
