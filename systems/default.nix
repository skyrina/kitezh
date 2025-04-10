{
  inputs,
  ...
}:
let
  inherit (inputs.nixpkgs.lib) nixosSystem;

  mkNode =
    name:
    {
      system,
      type ? nixosSystem,
    }:
    let
      conf = import (./. + "/${name}/default.nix");
      pkgs = import inputs.nixpkgs {
        inherit system;
      };
      specialArgs = { inherit inputs; };
    in
    type {
      inherit system specialArgs;
      modules = [
        { nixpkgs.pkgs = pkgs; }
        {
          # this is for using in deployment module
          _module.args = {
            _specialArgs = specialArgs;
            # we don't use the already existing modules option because that includes setting nixpkgs
            # which colmena doesn't like since it sets it itself
            _modules = [ conf ];
            _pkgs = pkgs;
          };
        }
        conf
      ];
    };
in
{
  flake.nixosConfigurations = builtins.mapAttrs mkNode {
    molly = {
      system = "x86_64-linux";
    };
  };
}
