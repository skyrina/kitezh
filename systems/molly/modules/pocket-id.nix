{
  config,
  ...
}:
let
  domain = "id.purr.systems";
  cfg = config.services.pocket-id.settings;
in
{
  services.pocket-id = {
    enable = true;
    dataDir = "/media/pocket-id";
    settings = {
      APP_URL = "https://id.purr.systems";
      TRUST_PROXY = true;
      PORT = 6823;
      ANALYTICS_DISABLED = true;
    };
  };

  services.caddy.virtualHosts."${domain}".extraConfig = ''
    reverse_proxy http://127.0.0.1:${toString cfg.PORT}
  '';
}
