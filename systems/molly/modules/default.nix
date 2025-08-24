{ ... }:
{
  imports = [
    ./arr.nix
    # ./asf.nix
    ./caddy.nix
    ./forge.nix
    ./grafana.nix
    ./headscale.nix
    ./immich.nix
    ./invidious.nix
    ./minio.nix # TODO: replace this with something else
    # ./netbird.nix
    ./ntfy.nix
    ./paperless.nix
    ./pds.nix
    ./pocket-id.nix
    ./thermo.nix
    ./vaultwarden.nix
    ./wg.nix
  ];
}
