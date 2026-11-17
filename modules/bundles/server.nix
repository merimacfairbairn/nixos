{self, ...}: {
  flake.modules.nixos.server = let
    modules = with self.modules.nixos; [
      base
      docker
      tailscale
      containers
    ];
  in
    {lib, ...}: {
      imports = modules;

      options = {
        tailnet = lib.mkOption {
          type = lib.types.str;
          description = "Tailnet name such as 'tail1234.ts.net'";
          default = "cuttlefish-gentoo.ts.net";
        };
      };

      config = {
        services.tailscale = {
          extraUpFlags = ["--advertise-tags=tag:server"];
        };
      };
    };
}
