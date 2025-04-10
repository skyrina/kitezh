{
  config,
  lib,
  self,
  inputs,
  ...
}:
let
  cfg = config.deployment;

  l = lib // builtins;
  t = l.types;
in
{
  options = {
    deployment.nixpkgs = l.mkOption {
      type = t.raw;
      default = inputs.nixpkgs.legacyPackages.x86_64-linux;
    };
    deployment.nodes = l.mkOption {
      type = t.listOf (t.submoduleWith {
        modules = [./node.nix];
        specialArgs = {inherit self inputs;};
      });
      default = {};
    };
  };
  config = let
    nodes = l.listToAttrs (l.map (node: { inherit (node) name; value = node; }) cfg.nodes);
    colmena = (l.mapAttrs (_: node: node.colmenaConfig) nodes) // {
      meta = {
        nixpkgs = cfg.nixpkgs;
        nodeNixpkgs = l.mapAttrs (_: node: node.pkgs) nodes;
        nodeSpecialArgs = l.mapAttrs (_: node: node.specialArgs) nodes;
      };
    };
  in {
    flake.colmena = colmena;
    flake.colmenaHive = inputs.colmena.lib.makeHive colmena;
  };
}
