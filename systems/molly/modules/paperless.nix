{ config, ... }:
let
  cfg = config.services.paperless;
in
{
  services.paperless = {
    enable = true;
    dataDir = "/media/paperless";
    settings.PAPERLESS_URL = "https://paperless.purr.systems";
  };

  services.caddy.virtualHosts."paperless.purr.systems".extraConfig = ''
    reverse_proxy http://127.0.0.1:${toString cfg.port}
  '';
}
