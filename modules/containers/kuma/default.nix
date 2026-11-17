{
  flake.modules.nixos.containerKuma = {config, ...}: let
    host = config.preferences.tailnetHost;
    dir = "/var/lib/uptime-kuma";
  in {
    systemd.tmpfiles.rules = ["d ${dir} 0755 root root -"];

    virtualisation.oci-containers.containers.kuma = {
      image = "docker.io/louislam/uptime-kuma:2";
      volumes = ["${dir}:/app/data"];
      ports = ["127.0.0.1:13001:3001"];
    };

    # https://<host>:3001
    services.caddy.virtualHosts."${host}:3001".extraConfig = ''
      reverse_proxy 127.0.0.1:13001
    '';
    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [3001];
  };
}
