{config, self, lib, ...}:
let
  l = lib // builtins;
  t = l.types;

  cfg = config;
in
{
  options = {
    name = l.mkOption {
      type = t.str;
    };
    nixosConfiguration = l.mkOption {
      type = t.nullOr t.raw;
      default = null;
    };
    modules = l.mkOption {
      type = t.listOf t.raw;
    };
    pkgs = l.mkOption {
      type = t.raw;
    };
    specialArgs = l.mkOption {
      type = t.attrs;
    };
    deployment = l.mkOption {
      type = t.attrs;
    };
    colmenaConfig = l.mkOption {
      type = t.raw;
      readOnly = true;
    };
  };
  config = let
    nixosConfiguration = if cfg.nixosConfiguration == null then self.nixosConfigurations.${cfg.name} else cfg.nixosConfiguration;
  in {
    specialArgs = nixosConfiguration._module.args._specialArgs;
    modules = nixosConfiguration._module.args._modules;
    pkgs = nixosConfiguration._module.args._pkgs;
    colmenaConfig = {
      imports = cfg.modules;
      deployment = cfg.deployment;
    };
  };
}
