{
  flake.modules.nixos.containerHomepage = {config, ...}: let
    name = "homepage";
    dir = "/var/lib/homepage";
  in {
    sops.secrets = {
      immich-api-key.sopsFile = ../secrets/secrets.yaml;
      ha-token.sopsFile = ../secrets/secrets.yaml;
    };
    sops.templates."homepage.env".content = ''
      HOMEPAGE_VAR_IMMICH_KEY=${config.sops.placeholder.immich-api-key}
      HOMEPAGE_VAR_HA_TOKEN=${config.sops.placeholder.ha-token}
    '';

    services.homepage-dashboard = {
      enable = true;
      listenPort = 13000;
      allowedHosts = "${name}.${config.tailnet}";
      environmentFiles = [config.sops.templates."homepage.env".path];

      services = [
        {
          "Self-hosted" = [
            {
              Immich = {
                href = "https://immich.${config.tailnet}";
                widget = {
                  type = "immich";
                  url = "http://localhost:12283";
                  key = "{{HOMEPAGE_VAR_IMMICH_KEY}}";
                  version = 2;
                };
              };
            }
            {
              "Uptime Kuma" = {
                href = "https://uptime-kuma.${config.tailnet}";
                widget = {
                  type = "uptimekuma";
                  url = "http://localhost:13001";
                  slug = "homelab"; # slug of a Kuma status page
                };
              };
            }
            {
              "Home Assistant" = {
                href = "https://home-assistant.${config.tailnet}";
                widget = {
                  type = "homeassistant";
                  url = "http://localhost:8123";
                  key = "{{HOMEPAGE_VAR_HA_TOKEN}}";
                };
              };
            }
          ];
        }
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
        tailscale serve --service=svc:${name} --https=443 http://localhost:13000
      '';
    };
  };
}
