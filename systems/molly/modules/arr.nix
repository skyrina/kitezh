{ config, pkgs, ... }:
let
  ports.jellyfin = 8096;
  prefix = "/media/arr";
in
{
  services.jellyfin.enable = true;
  services.jellyfin.cacheDir = "${prefix}/jellyfin/cache";
  services.jellyfin.configDir = "${prefix}/jellyfin/config";
  services.jellyfin.dataDir = "${prefix}/jellyfin/data";

  services.caddy.virtualHosts."jellyfin.nyaa.bar" = {
    serverAliases = [ "jellyfin.nya" ];
    extraConfig = ''
      import cloudflare
      import private
      reverse_proxy http://127.0.0.1:${toString ports.jellyfin}
    '';
  };

  services.sonarr.enable = true;
  services.sonarr.dataDir = "${prefix}/sonarr";

  services.caddy.virtualHosts."sonarr.nya".extraConfig = ''
    import private
    reverse_proxy http://127.0.0.1:${toString config.services.sonarr.settings.server.port}
  '';

  services.radarr.enable = true;
  services.radarr.dataDir = "${prefix}/radarr";

  services.caddy.virtualHosts."radarr.nya".extraConfig = ''
    import private
    reverse_proxy http://127.0.0.1:${toString config.services.radarr.settings.server.port}
  '';

  services.prowlarr.enable = true;

  services.caddy.virtualHosts."prowlarr.nya".extraConfig = ''
    import private
    reverse_proxy http://127.0.0.1:${toString config.services.prowlarr.settings.server.port}
  '';

  services.flaresolverr.enable = true;
  # todo: remove once https://github.com/NixOS/nixpkgs/pull/388775 is merged
  services.flaresolverr.package = pkgs.flaresolverr.overrideAttrs (
    final: prev: {
      version = "3.3.21-unstable-2025-03-04";

      src = pkgs.fetchFromGitHub {
        owner = "FlareSolverr";
        repo = "FlareSolverr";
        rev = "ce5369dd413cd71a81ce38a5ccd379f6c9352e23";
        hash = "sha256-cZ/YT4H2OU5l3AosROnkoyT5qrva5lxKshQMS626f2E=";
      };

      meta = builtins.removeAttrs prev.meta [ "broken" ];
    }
  );
}
