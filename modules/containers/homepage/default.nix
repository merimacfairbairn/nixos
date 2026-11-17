{
  flake.modules.nixos.containerHomepage = {config, ...}: let
    host = config.preferences.tailnetHost;
    dir = "/var/lib/homepage";
  in {
    systemd.tmpfiles.rules = ["d ${dir} 0755 root root -"];

    virtualisation.oci-containers.containers.homepage = {
      image = "ghcr.io/gethomepage/homepage:latest";
      ports = ["127.0.0.1:13000:3000"];
      volumes = ["${dir}:/app/config"];
      environment.HOMEPAGE_ALLOWED_HOSTS = host;
    };

    # https://<host>  (443)
    services.caddy.virtualHosts."${host}".extraConfig = ''
      reverse_proxy 127.0.0.1:13000
    '';
    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [443];
  };
}
