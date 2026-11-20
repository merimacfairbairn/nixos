{
  flake.modules.nixos.integrationMatterServer = {
    services.matterjs-server = {
      enable = true;
      port = 5580;
    };
  };
}
