{ config, pkgs, ... }:
let
  ports.jellyfin = 8096;
  prefix = "/media/arr";
in
{
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
    ];
  };

  services.jellyfin.enable = true;
  services.jellyfin.cacheDir = "${prefix}/jellyfin/cache";
  services.jellyfin.configDir = "${prefix}/jellyfin/config";
  services.jellyfin.dataDir = "${prefix}/jellyfin/data";

  services.caddy.virtualHosts."jellyfin.purr.systems" = {
    serverAliases = [ "jellyfin.nya" ];
    extraConfig = ''
      import cloudflare
      import private
      reverse_proxy http://127.0.0.1:${toString ports.jellyfin}
    '';
  };

  services.sonarr.enable = true;
  services.sonarr.dataDir = "${prefix}/sonarr";

  services.caddy.virtualHosts."sonarr.purr.systems".extraConfig = ''
    import private
    reverse_proxy http://127.0.0.1:${toString config.services.sonarr.settings.server.port}
  '';

  services.radarr.enable = true;
  services.radarr.dataDir = "${prefix}/radarr";

  services.caddy.virtualHosts."radarr.purr.systems".extraConfig = ''
    import private
    reverse_proxy http://127.0.0.1:${toString config.services.radarr.settings.server.port}
  '';

  services.prowlarr.enable = true;
  services.prowlarr.dataDir = "${prefix}/prowlarr";

  services.caddy.virtualHosts."prowlarr.purr.systems".extraConfig = ''
    import private
    reverse_proxy http://127.0.0.1:${toString config.services.prowlarr.settings.server.port}
  '';

  services.flaresolverr.enable = true;

  age.secrets."transmission.json".file = ../../../secrets/transmission.json.age;

  services.transmission = {
    enable = true;
    # TODO: revert to pkgs.transmission_4 once version > 4.0.6
    # package = pkgs.transmission_4;
    package = pkgs.transmission_4.overrideAttrs (
      final: prev: {
        version = "4.0.5";
        src = pkgs.fetchFromGitHub {
          owner = "transmission";
          repo = "transmission";
          rev = final.version;
          hash = "sha256-gd1LGAhMuSyC/19wxkoE2mqVozjGPfupIPGojKY0Hn4=";
          fetchSubmodules = true;
        };
      }
    );
    home = "${prefix}/transmission";
    openRPCPort = true;
    downloadDirPermissions = "775";
    settings = {
      umask = "002"; # let "media" group write
      rpc-authentication-required = true;
      rpc-host-whitelist-enabled = false;
      rpc-whitelist = "127.0.0.1,192.168.1.*,10.0.0.*";
      rpc-username = "user";
      rpc-bind-address = "0.0.0.0";
      download-dir = "${prefix}/library/downloads";
    };
    credentialsFile = config.age.secrets."transmission.json".path;
  };

  users.groups.media = { };
  services.jellyfin.group = "media";
  services.sonarr.group = "media";
  services.radarr.group = "media";
  services.transmission.group = "media";
}
