{
  moduleWithSystem,
  self,
  inputs,
  ...
}: {
  flake.nixosModules.hyprland = moduleWithSystem ({
    self',
    pkgs,
    inputs',
    ...
  }: {config, ...}: let
    modules = with self.nixosModules; [
      audio
      systemTheme
      quickshell
    ];

    runtimePkgs = self'.packages.hyprland.passthru.runtimePackages;
    lib = pkgs.lib;

    runtimeTarget = name: pkg:
      if config.security.wrappers ? ${name}
      then "/run/wrappers/bin/${name}"
      else lib.getExe pkg;
  in {
    imports = modules;

    options = {
      tabletSupport = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable tablet support across all modules";
      };
    };

    config = {
      programs.hyprland = {
        enable = true;
        package = self'.packages.hyprland;
      };

      services.displayManager.defaultSession = "hyprland";
      services.xserver.enable = true;
      services.seatd.enable = true;
      security.polkit.enable = true;

      environment.systemPackages = with pkgs; [
        gsettings-desktop-schemas
        glib
      ];

      system.activationScripts.hyprRuntimeEnv = lib.stringAfter ["specialfs"] ''
        mkdir -p /run/hypr-runtime-env/bin
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: pkg: ''
            ln -sfn ${runtimeTarget name pkg} /run/hypr-runtime-env/bin/${name}
          '')
          runtimePkgs)}
      '';

      system.activationScripts.hyprConfig = let
        hyprgrassPath = "${inputs'.hyprgrass.packages.default}/lib/libhyprgrass.so";
        pluginFile = pkgs.writeText "plugins.lua" ''
          hl.on("hyprland.start", function ()
          ${lib.optionalString config.tabletSupport ''
            hl.exec_cmd("hyprctl plugin load ${hyprgrassPath}")
          ''}
          end)
        '';

        # Easy way to get nix runtime info (ie the directory the config is at)
        # into hyprland to run commands and stuff
        runtimeFile = pkgs.writeText "runtime.lua" '' '';
      in
        lib.stringAfter ["specialfs"] ''
               mkdir -p /run/hypr/config
          rm -rf /run/hypr/config/*
               ln -sfn ${inputs'.hyprland.packages.repo-files}/* /run/hypr/config
               ln -sfn ${pluginFile} /run/hypr/config/plugins.lua
               ln -sfn ${runtimeFile} /run/hypr/config/runtime.lua
        '';
    };
  });
  perSystem = {
    self',
    system,
    inputs',
    ...
  }: {
    packages = {
      hyprland = inputs'.hyprland.packages.default.override {
        flags."--config" = "/run/hypr/config/hyprland.lua";
        env."MODULES_ROOT" = "/run/hypr/config/modules";
        env."HYPRLAND_ROOT" = "/run/hypr/config";
        runtimePackages =
          inputs.hyprland.lib.RuntimePkgs.${system}
          // {
            kitty = self'.packages.kitty;
            wpaperd = self'.packages.wpaperd;
            # otter-launcher = self'.packages.otter-launcher;
            # hyprlock = self'.packages.hyprlock;
            quickshell = self'.packages.quickshell;
          };
      };
    };
  };
}
