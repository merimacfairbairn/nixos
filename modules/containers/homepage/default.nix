{
  flake.modules.nixos.containerHomepage = {config, ...}: {
    systemd.services.tailscale-serve-homepage = {
      after = ["tailscaled.service" "network-online.target"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = "${config.services.tailscale.package}/bin/tailscale serve --bg --https=10000 3001";
    };

    virtualisation.oci-containers.containers.homepage = {
      image = "ghcr.io/gethomepage/homepage:latest";
      ports = ["127.0.0.1:3000:3000"];
      volumes = ["/var/lib/homepage:/app/config"];
      environment.HOMEPAGE_ALLOWED_HOSTS = "server01.tail69c545.ts.net";
    };
  };
}
