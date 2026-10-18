{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    wrappers = {
      url = "github:nix-community/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvim.url = "github:merimacfairbairn/nvim";

    hyprland = {
      url = "github:merimacfairbairn/hypr";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickshell = {
        url = "github:merimacfairbairn/quickshell";
        flake = false;
    };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./modules);
}
