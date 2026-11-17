{
  flake.modules.nixos.containerCaddy = {
    config,
    lib,
    ...
  }: {
    options.preferences.tailnetHost = lib.mkOption {
      type = lib.types.str;
      default = "server01.cuttlefish-gentoo.ts.net";
      description = "MagicDNS FQDN of this host; certs are issued by tailscaled";
    };

    config = {
      # Let Caddy fetch *.ts.net certs from tailscaled
      services.tailscale.permitCertUid = "caddy";

      services.caddy = {
        enable = true;
        globalConfig = ''
          auto_https disable_redirects
        '';
      };
    };
  };
}
