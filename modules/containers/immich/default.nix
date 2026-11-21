{self, ...}: {
  flake.modules.nixos.containerImmich = {
    config,
    pkgs,
    ...
  }: let
    version = "v3.4.1";
    name = "immich";
    dir = "/var/lib/immich";
    docker = "${pkgs.docker}/bin/docker";
    net = ["--network=immich"];
    envFile = [config.sops.templates."immich.env".path];
  in {
    sops.secrets.immich-db-password.sopsFile = ../secrets/secrets.yaml;
    sops.templates."immich.env".content = ''
      DB_PASSWORD=${config.sops.placeholder.immich-db-password}
      POSTGRES_PASSWORD=${config.sops.placeholder.immich-db-password}
    '';

    systemd.tmpfiles.rules = [
      "d ${dir}/upload 0755 root root -"
      "d ${dir}/postgres 0700 999 999 -"
      "d ${dir}/model-cache 0755 root root -"
    ];

    systemd.services.docker-network-immich = {
      after = ["docker.service"];
      requires = ["docker.service"];
      before = map (n: "docker-${n}.service") [
        "immich-server"
        "immich-postgres"
        "immich-redis"
        "immich-ml"
      ];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = "${docker} network inspect immich >/dev/null 2>&1 || ${docker} network create immich";
    };

    virtualisation.oci-containers.containers = {
      immich-postgres = {
        image = "ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0";
        environment = {
          POSTGRES_USER = "immich";
          POSTGRES_DB = "immich";
          POSTGRES_INITDB_ARGS = "--data-checksums";
        };
        environmentFiles = envFile;
        volumes = ["${dir}/postgres:/var/lib/postgresql/data"];
        extraOptions = net;
      };
      immich-redis = {
        image = "docker.io/valkey/valkey:8-bookworm";
        extraOptions = net;
      };
      immich-ml = {
        image = "ghcr.io/immich-app/immich-machine-learning:${version}";
        volumes = ["${dir}/model-cache:/cache"];
        extraOptions = net;
      };
      immich-server = {
        image = "ghcr.io/immich-app/immich-server:${version}";
        dependsOn = ["immich-postgres" "immich-redis" "immich-ml"];
        environment = {
          DB_HOSTNAME = "immich-postgres";
          DB_USERNAME = "immich";
          DB_DATABASE_NAME = "immich";
          REDIS_HOSTNAME = "immich-redis";
          IMMICH_MACHINE_LEARNING_URL = "http://immich-ml:3003";
        };
        environmentFiles = envFile;
        volumes = ["${dir}/upload:/data" "/etc/localtime:/etc/localtime:ro"];
        ports = ["12283:2283"];
        extraOptions = net;
      };
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
        tailscale serve --service=svc:${name} --https=443 http://localhost:12283
      '';
    };

    networking.firewall.interfaces."wlp3s0" = {
      allowedTCPPorts = [12283];
    };
  };
}
