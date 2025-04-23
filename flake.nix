{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    impermanence.url = "github:nix-community/impermanence";

    flake-parts.url = "github:hercules-ci/flake-parts";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    colmena.url = "github:zhaofengli/colmena";
    colmena.inputs.nixpkgs.follows = "nixpkgs";

    thermo.url = "git+https://git.purr.systems/sky/thermo.git";
    thermo.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      flake-parts,
      ...
    }@inputs:
    let
      # inherit (self) outputs;
      l = inputs.nixpkgs.lib // builtins;
      skylib = import ./lib;
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        # "aarch64-linux"
        "x86_64-linux"
      ];

      imports = l.flatten [
        skylib.deploymentModule
        ./systems
      ];

      deployment.nodes = skylib.importFolder ./deployments;

      # flake.nixosConfigurations.lsp = inputs.nixpkgs.lib.nixosSystem {
      #   system = "x86_64-linux";
      #   modules = [
      #     (import ./systems/molly)
      #   ];
      #   specialArgs = { inherit inputs outputs; };
      # };

      perSystem =
        {
          pkgs,
          inputs',
          ...
        }:
        {
          debug = true;

          formatter = pkgs.nixfmt-rfc-style;

          devShells.default =
            let
              inherit (inputs'.colmena.packages) colmena;
              inherit (inputs'.agenix.packages) agenix;
            in
            pkgs.mkShell {
              buildInputs = with pkgs; [
                sops
                colmena
                nixfmt-rfc-style
                nixd
                nil
                agenix
              ];
            };
        };
    };
}
