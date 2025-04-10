{
  lib,
  config,
  inputs,
  ...
}:
{
  # This will add each flake input as a registry
  # To make nix3 commands consistent with your flake
  nix.registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

  # This will additionally add your inputs to the system's legacy channels
  # Making legacy nix commands consistent as well, awesome!
  nix.nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

  nix.settings.experimental-features = "nix-command flakes";
  nix.settings.auto-optimise-store = true;
}
