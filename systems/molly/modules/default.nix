{ ... }:
{
  imports = [
    ./arr.nix
    ./asf.nix
    ./caddy.nix
    ./forge.nix
    ./grafana.nix
    ./immich.nix
    ./invidious.nix
    ./minio.nix # TODO: replace this with something else
    ./ntfy.nix
    ./paperless.nix
    ./pds.nix
    ./thermo.nix
    ./vaultwarden.nix
    ./wg.nix
  ];
}
