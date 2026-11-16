{
  flake.modules.nixos.containerKuma = {config, ...}: let
    dir = "/var/lib/uptime-kuma";
  in {
    systemd.tmpfiles.rules = ["d ${dir} 0755 root root -"];

    systemd.services.tailscale-serve-kuma = {
      after = ["tailscaled.service" "network-online.target"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = "${config.services.tailscale.package}/bin/tailscale serve --bg --https=8443 3001";
    };

    virtualisation.oci-containers.containers.kuma = {
      image = "docker.io/louislam/uptime-kuma:2";
      volumes = ["${dir}:/app/data"];
      ports = ["127.0.0.1:3001:3001"];
    };
  };
}
