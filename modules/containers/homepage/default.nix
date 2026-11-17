{
  flake.modules.nixos.containerHomepage = {config, ...}: let
    name = "homepage";
    dir = "/var/lib/homepage";
  in {
    systemd.tmpfiles.rules = ["d ${dir} 0755 root root -"];

    virtualisation.oci-containers.containers.homepage = {
      image = "ghcr.io/gethomepage/homepage:latest";
      ports = ["127.0.0.1:13000:3000"];
      volumes = ["${dir}:/app/config"];
      environment.HOMEPAGE_ALLOWED_HOSTS = "${name}.${config.tailnet}";
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
        tailscale serve --service=svc:${name} --https=443 http://localhost:13000
      '';
    };
  };
}
