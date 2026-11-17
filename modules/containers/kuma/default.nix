{
  flake.modules.nixos.containerKuma = {config, ...}: let
    name = "uptime-kuma";
    dir = "/var/lib/uptime-kuma";
  in {
    systemd.tmpfiles.rules = ["d ${dir} 0755 root root -"];

    virtualisation.oci-containers.containers.kuma = {
      image = "docker.io/louislam/uptime-kuma:2";
      volumes = ["${dir}:/app/data"];
      ports = ["127.0.0.1:13001:3001"];
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
        tailscale serve --service=svc:${name} --https=443 http://localhost:13001
      '';
    };
  };
}
