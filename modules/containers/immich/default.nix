{self, ...}: {
  flake.modules.nixos.containerImmich = {
    config,
    pkgs,
    ...
  }: let
    version = "release";
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
      "d ${dir}/postgres 0700 root root -"
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

    # Server with tailscale
    systemd.services.tailscale-serve-immich = {
      after = ["tailscaled.service" "network-online.target"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      script = "${config.services.tailscale.package}/bin/tailscale serve --bg 2283";
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
        ports = ["127.0.0.1:2283:2283"];
        extraOptions = net;
      };
    };
  };
}
